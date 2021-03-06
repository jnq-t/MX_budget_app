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

    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    def read_institution(institution_code)
      HTTP.headers(:accept => @@accept)
      .basic_auth(:user => ENV["API_USERNAME"],
                  :pass => ENV["API_PASSWORD"])
      .get("#{@@base_url}/institutions/#{institution_code}").parse["institution"]
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
    response = HTTP.headers(:accept => @@accept, :'content-type' => @@content_type).basic_auth(:user => ENV["API_USERNAME"], :pass => ENV["API_PASSWORD"])
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
      members =  Member.where("user_guid = ?", self.guid)
      if members
          members.delete_all
      end
      #delete user object from database
      self.delete
      return code
    else
      return "delete request unsuccessful, response code: #{code}"
    end
  end

  #MEMBER METHODS 
  def create_member(institution_code = "mxbank", username = "mxuser", password = "password")
    #query institution credentials
    credentials = HTTP.headers(:accept=>@@accept).basic_auth(:user => ENV["API_USERNAME"], :pass => ENV["API_PASSWORD"])
    .get("#{@@base_url}/institutions/#{institution_code}/credentials").parse["credentials"]

    if credentials
      credentials_array = [{ :guid => credentials[0]["guid"], :value => username}, {:guid => credentials[1]["guid"], :value=> password}]
      #POST create new member
      post_response = HTTP.headers(:accept => @@accept, :'content-type' => @@content_type).basic_auth(:user => ENV["API_USERNAME"], :pass => ENV["API_PASSWORD"])
      .post("#{@@base_url}/users/#{self.guid}/members", :json => { :member => { :credentials=> credentials_array,
                                                                   :institution_code => institution_code} })
      #create member in db
      if post_response.code == 202
        post_response = post_response.parse["member"]
        temp_member = Member.new()
        post_response.each_pair do |key, value|
          unless key == "id"
            if Member.attribute_names.include? key
              temp_member.update_attribute("#{key}", post_response["#{key}"])
            end
          end
        end
        if !temp_member.valid?
          return "problem creating member"
        else 
          temp_member.save
          return temp_member
        end 
      elsif post_response.code == 404
        #404 eror patch
        self.update_members
        return self.find_members

      else  
        return post_response.code
      end
    end
  end

  def check_status_persistent(member_guid)
    begin
      http = HTTP.headers(:accept => @@accept).basic_auth(:user => ENV["API_USERNAME"], 
                                                          :pass => ENV["API_PASSWORD"])
                  .persistent "#{@@base_url}"
      status = http.get("/users/#{self.guid}/members/#{member_guid}/status").parse["member"]["connection_status"]
    rescue
      return "error conecting to API"
    else
      # while status == "CREATED" do 
      #   status = http.get("/users/#{self.guid}/members/#{member_guid}/status").parse["member"]["connection_status"]
      # end
      for i in 0..100 do
        if status == "CREATED"
          status = http.get("/users/#{self.guid}/members/#{member_guid}/status").parse["member"]["connection_status"]
        else
          return status
        end
      end
    ensure 
      http.close if http
    end
    return 1
  end

    #list members associated with user in API
    def list_members
      HTTP.headers(:accept => @@accept, "content-type" => @@content_type).basic_auth(:user => ENV["API_USERNAME"], :pass => ENV["API_PASSWORD"])
      .get("#{@@base_url}/users/#{self.guid}/members").parse["members"]
    end

    #return member objects assosiated with user in db
  def find_members 
    Member.where(:user_guid => self.guid)
  end

  #updates db to match api records
  def update_members
    unless self.list_members.blank?
      #create new members
      self.list_members.each do |api_member|
        member_params = {}
        api_member.each_pair do |key, value|
          unless key == "id"
            if Member.attribute_names.include? key
              member_params[key] = value
            end
          end
        end
        #member already exists
        temp = Member.find_by guid: member_params["guid"]
        if !!temp
          temp.attributes = member_params
          if temp.valid? 
            temp.save
          else
            return "problem updating existing member"
          end
        else
          member = Member.new(member_params)
          if member.valid?
            member.save
          else
            return "problem with member params"
          end
        end
        #delete denied members
        if api_member["connection_status"] != "CONNECTED"
          Member.find_by(guid: member_params["guid"]).delete
          Member.delete_member(self.guid, member_params["guid"])
        end
      end
    end
  end

  #ACCONTS LOGIC  

  #lists all accounts associated with self
  def list_accounts
    HTTP.headers(:accept => @@accept).basic_auth(:user => ENV["API_USERNAME"], :pass => ENV["API_PASSWORD"])
    .get("#{@@base_url}/users/#{self.guid}/accounts").parse["accounts"]
  end

  #parses accounts based on given paramaters
  def account_details(*paramaters)
    accounts = []
    unless self.list_accounts.blank?
      self.list_accounts.each do |account|
        details = {}      
        account.each do |key, value|
          if paramaters.include? key
            details[key] = value
          end
        end
        accounts << details
      end
      accounts
    end
  end

  def account_belongs_to(account_guid)
    institution_code = HTTP.headers(:accept => @@accept).basic_auth(:user => ENV["API_USERNAME"], :pass => ENV["API_PASSWORD"])
    .get("#{@@base_url}/users/#{self.guid}/accounts/#{account_guid}").parse["account"]["institution_code"]

    self.class.read_institution(institution_code)["name"]
  end

  
  #TRANSACTIONS LOGIC
  def list_transactions(page = 1, records_per_page = 100)
    HTTP.headers(:accept => @@accept).basic_auth(:user => ENV["API_USERNAME"], :pass => ENV["API_PASSWORD"])
    .get("#{@@base_url}/users/#{self.guid}/transactions", params: { :page => page, :records_per_page => records_per_page})
  end

  def transaction_details(page = 1, records_per_page = 25, *paramaters)
    transactions = []
    if self.list_transactions(page, records_per_page).nil?
      "no transactions available"
    else 
      self.list_transactions(page, records_per_page).parse["transactions"].each do |transaction|
        details = {} 
        transaction.each do |key, value|
          if paramaters.include? key 
            details[key] = value
          end
        end
        transactions << details
      end
      transactions
    end
  end

  

  def transactions_this_month(month = Time.now.month)
    spent_this_month = 0
    transactions = []
    current_page = 1
    page = self.list_transactions(current_page).parse["transactions"]
    if page.blank? 
      return "error listing transactions"
    end
    #loop list_transactions 
    while page[0]["transacted_at"].to_datetime.month >= month
      #loop through response
      page.each do |transaction|
        if transaction["transacted_at"].to_datetime.month == month && transaction["is_expense"] == true
          transactions.append(transaction)
          spent_this_month += transaction["amount"]
        end
      end
      current_page += 1
      page = self.list_transactions(current_page).parse["transactions"]
      if page.blank?
        break 
      end  
    end
    if transactions.empty?
      "no transactions avaible for given month"
    else
      return {:transactions => transactions, :spent_this_month => spent_this_month} 
    end
  end

  #INCOME LOGIC
  def create_income(name, amount, date)
    date.to_datetime
    Income.create(name: name, amount: amount, date: date, user_guid: self.guid)
  end

  def list_income(month = Time.now.month)
    total = 0 
    income_details = []
    income_all = Income.where(:user_guid => self.guid)
    if income_all.empty?
      return "No income"
    end
    income_all.each do |income|
      if income[:date].to_datetime.month == month
        total += income.amount
        income_details.append(income)
      end
    end
    if income_details.empty?
      return "no income for the designated month"
    end
    return {:income_details => income_details, :total => total}
  end

#EXPENSE LOGIC 

def create_expense(name, amount, date, description = nil)
    date.to_datetime
    Expense.create(name: name, amount: amount, date: date, user_guid: self.guid, description: description)
  end

  def list_expenses(month = Time.now.month)
    total = 0 
    expense_details= []
    expense_all= Expense.where(:user_guid => self.guid)
    if expense_all.empty?
      return "No expenses"
    end
    expense_all.each do |expense|
      if expense[:date].to_datetime.month == month
        total += expense.amount
        expense_details.append(expense)
      end
    end
    if expense_details.empty?
      return "no expenses for the designated month"
    end
    return {:expense_details=> expense_details, :total => total}
  end
end