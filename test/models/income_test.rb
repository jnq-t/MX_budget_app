require "test_helper"

class IncomeTest < ActiveSupport::TestCase
  def setup
    @income = Income.new(user_guid: "USR-12345678-1234-1234-1234-1234567890ab", name: "Income Test", amount: 500, date: Time.now)
  end

  test "should be valid" do
    assert @income.valid?
  end

  test "should have valid user guid" do
    @income.user_guid = " " 
    assert_not @income.valid? 
  end

  test "invalid guids should be invalid" do 
    invalid_guids = %w[USR-1234-12345678-1234-1234567890ab-1234 USR-12345678-1234-1234-1234-1234567890a USR;12345678,1234.1234-1234!1234567890ab]
    invalid_guids.each do |invalid_guid|
      @income.user_guid = invalid_guid
      assert_not @income.valid?, "#{invalid_guid.inspect} should be invalid"
    end
  end
end
