class MembersController < ApplicationController
  def new
    @member = Member.new
  end

  def index 
  end

  def create
    render 'show'
  end

  def show 
  end


end
