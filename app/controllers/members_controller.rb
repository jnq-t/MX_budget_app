class MembersController < ApplicationController
  
  def new
    @member = Member.new
  end

  def index 
  end

  def create
    member = current_user.create_member(params[:member][:institution_code], params[:member][:username], params[:member][:password])
    if member == 409 
      flash.now[:danger] = "Membership with given credentials already in use!"
      render 'index'
    else
      #if successfully created
    status = current_user.check_status_persistent(Member.last.guid)
    if status == "CONNECTED"
      flash.now[:success] = view_context.link_to("Sucess! Link another account, or proceed to your budget", current_user)
      render 'index'
    else
      flash.now[:danger]  = "Problem connecting membership! Membership status: #{status}"
      current_user.update_members
      render 'index'
    end
    end
  end

  def show 
    current_user.update_members
  end

  def destroy
  end
end
