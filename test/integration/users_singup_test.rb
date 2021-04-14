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
  
  #EITHER MAKE THIS TEST WORK WITH THE API OR MAKE A WHOLE NEW LOGIC FOR IT>>>> SHOULD PROBABLY JUST MAKE IT WORK WITH THE API
  # test "valid signup information" do 
  #   get signup_path
  #   assert_difference 'User.count', 1 do
  #   post users_path, params: { user: { user_id: "SignUp Test",
  #                                      email: "user@signuptest.com",
  #                                      password: "password", 
  #                                      password_confirmation: "password" } } 
  #   end
  #   follow_redirect! 
  #   assert_template 'members/index'
  # end
end
