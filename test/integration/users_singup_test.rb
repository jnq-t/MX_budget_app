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
end
