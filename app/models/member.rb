class Member < ApplicationRecord
  VALID_MBR_REGEX = /MBR-[a-zA-z0-9]{8}-[a-zA-z0-9]{4}-[a-zA-z0-9]{4}-[a-zA-z0-9]{4}-[a-zA-z0-9]{12}/
  VALID_USR_REGEX = /USR-[a-zA-z0-9]{8}-[a-zA-z0-9]{4}-[a-zA-z0-9]{4}-[a-zA-z0-9]{4}-[a-zA-z0-9]{12}/
  validates :guid, presence: true, format: { with: VALID_MBR_REGEX }
  validates :user_guid, presence: true, format: { with: VALID_USR_REGEX }

  #VARIABLES 
  @@accept = "application/vnd.mx.api.v1+json"
  @@content_type = "application/json"
  @@base_url = "https://int-api.mx.com" 

  #CLASS METHODS 
  def self.delete_member(user_guid, member_guid)
      HTTP.headers(:accept => @@accept)
        .basic_auth(:user => ENV["API_USERNAME"] ,
                    :pass => ENV["API_PASSWORD"])
        .delete("#{@@base_url}/users/#{user_guid}/members/#{member_guid}").code
  end

  #INSTANCE METHODS

  def check_status 
    response = HTTP.headers(:accept => @@accept)
                   .basic_auth(:user => ENV["API_USERNAME"],
                               :pass => ENV["API_PASSWORD"])
                   .get("#{@@base_url}/users/#{self.user_guid}/members/#{self.guid}/status")
    return response.parse["member"]["connection_status"], "successfully aggregated at: #{response.parse["member"]["successfully_aggregated_at"]}"
  end

  def aggregate_member
    HTTP.headers(:accept => @@accept)
        .basic_auth(:user => ENV["API_USERNAME"], :pass => ENV["API_PASSWORD"])
        .post("https://int-api.mx.com/users/#{self.user_guid}/members/#{self.guid}/aggregate").status
  end
end
