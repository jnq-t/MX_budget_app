require "test_helper"

class UsersSingupTest < ActionDispatch::IntegrationTest

  test "invalid signup information" do 
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { user_id: "",
                                         email: "invalid@user",
                                         password:               "foo",
                                         password_confirmation: "bar" } }
      end
      assert_template 'users/new'
    end

  test "valid signup information" do 
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { user_id: "Example User",
                                         email: "user@example.com",
                                         password: "password", 
                                         password_confirmation: "password" } } 
    end
  follow_redirect! 
  assert_template 'members/index'
  end
end
