class CreateIncomes < ActiveRecord::Migration[6.1]
  def change
    create_table :incomes do |t|
      t.string :name
      t.datetime :date
      t.integer :amount
      t.string :user_guid

      t.timestamps
    end
  end
end
