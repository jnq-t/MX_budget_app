require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup 
    @user = User.new(user_id: "ExampleUser", email: "user@usertest.com",
                     password: "foobar", password_confirmation: "foobar")
    @VALID_USR_REGEX = /USR-[a-zA-z0-9]{8}-[a-zA-z0-9]{4}-[a-zA-z0-9]{4}-[a-zA-z0-9]{4}-[a-zA-z0-9]{12}/
    @VALID_MBR_REGEX = /MBR-[a-zA-z0-9]{8}-[a-zA-z0-9]{4}-[a-zA-z0-9]{4}-[a-zA-z0-9]{4}-[a-zA-z0-9]{12}/

  end

  test "should be valid" do 
    assert @user.valid? 
  end

  test "user_id should be present" do
    @user.user_id = "  "
    assert_not @user.valid?
  end

  test "email should be present" do 
    @user.email = "  "
    assert_not @user.valid? 
  end

  test "user_id should not be too long" do
    @user.user_id = "a" * 54 
    assert_not @user.valid?
  end

  test "user_id should not be too short" do 
    @user.user_id = "123" 
    assert_not @user.valid?
  end

  test "email should not be too long" do 
    @user.email = "a" * 244 + "@example.com" 
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

    test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end


  test "user_id should be unique" do 
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test "password should be nonblank" do 
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do 
    @user.password = @user.password_confirmation = "a" * 5 
    assert_not @user.valid?
  end

  test "user without associated API user cannot delete_self" do 
    assert_equal @user.delete_self, "user has no guid and will not be deleted"
  end

  test "test group for created user in API" do 
    
    #user should be successfully created
    response = @user.create_user
    assert_equal 200, response, "test user should be created" + " " + response.to_s

    #duplicate user should not be created 
    assert_equal "user name already taken", @user.create_user, "test duplicate user should not be created"
    #defaults should not be empty 
    assert_includes [true, false], @user.is_disabled, "test default boolean should be set" 
    assert @user.metadata, "test default metadata should be set"
    #read user should return same value as db
    assert_equal @user.read_user["id"], @user.user_id, "test read user has same user_id as database"

    #valid user guid 
    assert_match @VALID_USR_REGEX, @user.guid
    #persistent connection should raise a timeout error but the member should still be created
    @user.create_member
    members = @user.find_members
    assert_equal 1, members.length, "test user should have exactly one member"
    assert_match @VALID_MBR_REGEX, members[0]["guid"], "test member should have valid guid"


    #delete user
    assert_equal 204, @user.delete_self, "test user should be successfully deleted"
  end
end
