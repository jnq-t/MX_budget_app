class MembersController < ApplicationController
  
  def new
    @member = Member.new
  end

  def index 
  end

  def create
    begin
    member = current_user.create_member(params[:member][:institution_code], params[:member][:username], params[:member][:password])
    if !!member 
      status = member.check_status_persistent 
    end
    rescue
      flash.now[:danger] = "Trouble connecting with MX api, try again!" 
      render 'index'
    else
    if !!status && status == "CONNECTED"
        flash.now[:success] = view_context.link_to("Sucess! Link another account, or proceed to your budget", current_user)
        render 'index'
    elsif !!status && status == 1 
       flash.now[:danger] = view_context.link_to("It's taking a while to connect! Try againt or check membership statuses?", members_show_path)
       render 'index'
    elsif !!status
        flash.now[:danger]  = "Problem connecting membership! Membership status: #{status}"
        current_user.update_members
        render 'index'
    else 
      flash.now[:danger] = "Problem connecting membership! Try again?"
    end
  end
end


  def show 
    begin 
      current_user.update_members
    rescue 
      flash[:danger] = "Trouble connecting with the MX API, try again!" 
      redirect_to root_path
    end
  end

  def destroy
  end
end
