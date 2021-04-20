class ChangeIncomeDateToString < ActiveRecord::Migration[6.1]
  def change
      change_column(:incomes, :date, :string)
  end
end
