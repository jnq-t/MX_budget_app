class AddAmountToExpenses < ActiveRecord::Migration[6.1]
  def change
    add_column :expenses, :amount, :float
  end
end
