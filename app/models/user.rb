class User < ApplicationRecord
  #TODO MOVE USER MODEL IN, BIT BY BIT CHECKING THAT NOTHING BREAKS AND ALL DEPENDENCIES ARE WORKED OUT AS WE GO 
  before_save { email.downcase! } 
  validates :user_id, presence: true, length: { minimum: 4, maximum: 51}, 
                    uniqueness: true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i 
  validates :email, presence: true, length: { maximum: 255 }, 
                    format: { with: VALID_EMAIL_REGEX }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }

  #CLASS VARIABLES 
  @@accept = "application/vnd.mx.api.v1+json"
  @@content_type = "application/json"
  @@base_url = "https://int-api.mx.com" 
    
  #DEFAULTS  
  @@default_metadata = "yada yada" 
  @@default_is_disabled = false

  #CLASS METHODS 
  class << self
    def list_users
      HTTP.headers(:accept => @@accept)
      .basic_auth(:user => ENV["API_USERNAME"], 
        :pass => ENV["API_PASSWORD"])
        .get("#{@@base_url}/users").parse["users"] 
    end


    def delete_user(guid)
      HTTP.headers(:accept => @@accept)
      .basic_auth(:user => ENV["API_USERNAME"] ,
                  :pass => ENV["API_PASSWORD"])
      .delete("#{@@base_url}/users/#{guid}").code
    end
  end

  #INSTANCE METHODS
  def create_user 

    #check that username is not in use in API databse (move to helper?)
    users = self.class.list_users 
    unless users.empty?
      users.each do |user|
        if user["id"] == self.user_id
          return "user name already taken" 
        end
      end
    end

    #set defaults
    unless self.is_disabled
      self.update_attribute(:is_disabled, @@default_is_disabled) 
    end
    unless self.metadata
      self.update_attribute(:metadata,@@default_metadata) 
    end

    #POST create user 
    response = HTTP.headers(:accept => @@accept, "content-type" => @@content_type).basic_auth(:user => ENV["API_USERNAME"], :pass => ENV["API_PASSWORD"])
    .post("#{@@base_url}/users", :json => { :user => { :id => self.user_id, :is_disabled => self.is_disabled, :email => self.email, 
                                                 :metadata => self.metadata} })

    #user created succesfully  
    if response.code == 200 
      #update relevant fields in user model
      response_user= response.parse["user"]
      response_user.each_pair do |key, value|
        unless key == "id"
          self.update_attribute("#{key}", response_user["#{key}"])  
        end
      end
      #user succefully created
      response.code
    else  
      return response.parse["error"]["message"]
    end
  end

  def read_user
    HTTP.headers(:accept => @@accept).basic_auth(:user => ENV["API_USERNAME"], :pass => ENV["API_PASSWORD"])
    .get("#{@@base_url}/users/#{self.guid}").parse["user"]
  end




  def delete_self
    #checks that user has been initialized successfully in the API
    unless self.guid
     return "user has no guid and will not be deleted"
    end
   #call class delete method 
    code = self.class.delete_user(self.guid)
    if code == 204 
      # #delete associated members from DB (this mirrors the API functionality)
      # members =  Member.where("user_guid = ?", self.guid)
      # if members
      #     members.delete_all
      # end
      #delete user object from database
      self.delete
      return code
    else
      return "delete request unsuccessful, response code: #{code}"
    end
  end


end