require "test_helper"

class ExpenseTest < ActiveSupport::TestCase
  def setup
    @expense= Expense.new(user_guid: "USR-12345678-1234-1234-1234-1234567890ab", name: "Expense Test", amount: 500, date: Time.now )
  end

  test "should be valid" do
    assert @expense.valid?
  end

  test "should have valid user guid" do
    @expense.user_guid = " " 
    assert_not @expense.valid? 
  end

  test "valid description should be valid" do 
    @expense.description = "a" * 100
    assert @expense.valid?
  end

  test "invalid description should be invalid" do 
    @expense.description = "a" * 101
    assert_not @expense.valid?
  end

  test "invalid guids should be invalid" do 
    invalid_guids = %w[USR-1234-12345678-1234-1234567890ab-1234 USR-12345678-1234-1234-1234-1234567890a USR;12345678,1234.1234-1234!1234567890ab]
    invalid_guids.each do |invalid_guid|
      @expense.user_guid = invalid_guid
      assert_not @expense.valid?, "#{invalid_guid.inspect} should be invalid"
    end
  end
end
