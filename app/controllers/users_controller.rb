class UsersController < ApplicationController
  def index
    if logged_in?
    else
      redirect_to login_path
    end
  end


  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
    if logged_in?
      current_user.update_members
    end
  # rescue 
  #   redirect_to members_show_path
  end

  def create
    @user = User.new(user_params)
    if @user.save
      if @user.create_user == 200
        reset_session
        log_in @user
        flash[:success] = "Welcome to your budget! Choose accounts to link!"
        redirect_to members_path
      else
        render 'new'
      end
    else
      flash[:danger] = "Unable to connect to Platform API, please try again later" 
      render 'new'
    end
  end

  private

    def user_params
      params.require(:user).permit(:user_id, :email, :password, 
                                   :password_confirmation)
    end
end
