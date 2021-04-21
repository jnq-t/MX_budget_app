class ChangeIntToFloatIncomeAmount < ActiveRecord::Migration[6.1]
  def change
    change_column(:incomes, :amount, :float)
  end
end
