class IncomesController < ApplicationController
  def index
  end  


  def new
    @income = Income.new
  end

  def create
    @income = Income.new(income_params)
    if @income.save 
      flash[:success] = "Added income!" 
      redirect_to current_user
    else 
      flash[:danger] = "Problem adding income, try again!"
      render 'new'
    end
  end

  def destroy
    @incomes = Income.where(:user_guid => current_user.guid)
    if params[:_method] == "delete"
      Income.find_by(id: params[:id]).delete
      flash[:success]= "Income deleted!"
      redirect_to current_user
    end
  end

  private

    def income_params 
      params.require(:income).permit(:name, :amount, :date,
                                     :user_guid)
    end
end
