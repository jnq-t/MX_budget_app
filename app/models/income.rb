class Income < ApplicationRecord
  VALID_USR_REGEX = /USR-[a-zA-z0-9]{8}-[a-zA-z0-9]{4}-[a-zA-z0-9]{4}-[a-zA-z0-9]{4}-[a-zA-z0-9]{12}/
  validates :user_guid, presence: true, format: { with: VALID_USR_REGEX }
  validates :name, presence: true
  validates :date, presence: true 
  validates :amount, presence: true, numericality: true
end
