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
end