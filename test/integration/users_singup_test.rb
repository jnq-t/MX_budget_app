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
      assert_not !!flash[:danger]
    end
  
  test "valid signup information" do 
    get signup_path
    assert_difference 'User.count', 1 do
    post users_path, params: { user: { user_id: "SignUp Test",
                                       email: "user@signuptest.com",
                                       password: "password", 
                                       password_confirmation: "password" } } 
    end
    follow_redirect! 
    assert_template 'members/index'

    post members_path params: { member: { institution_code: "mxbank", 
                                                 username: "mxuser",
                                                 password: "password" } } 
    #every expected outcome for current_user.create_member generates a flash response
    assert_not flash.empty?
    #API cleanup
    User.last.delete_self
  end
end
