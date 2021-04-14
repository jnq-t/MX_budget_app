class MembersController < ApplicationController
  
  def new
    @member = Member.new
  end

  def index 
  end

  def create
    current_user.create_member(params[:member][:institution_code], params[:member][:username], params[:member][:password])
    flash.now[:success] = view_context.link_to("Sucess! Link another account, or proceed to your budget", current_user)
    render 'index'
  end

  def show 
  end


end
