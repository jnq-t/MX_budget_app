class ExpensesController < ApplicationController
  def new
    @expense = Expense.new
  end

  def create
     @expense= Expense.new(expense_params)
    if @expense.save 
      flash[:success] = "Added expense!" 
      redirect_to current_user
    else 
      flash[:danger] = "Problem adding expense, try again!"
      render 'new'
    end
  end

  def destroy
    @expenses= Expense.where(:user_guid => current_user.guid)
    if params[:_method] == "delete"
      Expense.find_by(id: params[:id]).delete
      flash[:success]= "Expense deleted!"
      redirect_to current_user
    end
  end

  private

    def expense_params 
      params.require(:expense).permit(:name, :amount, :date, 
                                      :description, :user_guid)
    end
end
