class CreateExpenses < ActiveRecord::Migration[6.1]
  def change
    create_table :expenses do |t|
      t.string :name
      t.string :description
      t.string :date
      t.string :user_guid

      t.timestamps
    end
  end
end
