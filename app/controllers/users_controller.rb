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
        begin
        current_user.update_members
        rescue 
        flash[:danger] = "Trouble Connecting, try again!"
        redirect_to root_path
      end
    end
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
    #user gave invalid params
    elsif @user.errors.any?
      #will render signup form with errors
      render 'new'
    #api is not creating a valid member, tell user to try again later
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
