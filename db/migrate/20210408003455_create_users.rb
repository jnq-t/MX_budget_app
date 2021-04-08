class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :guid
      t.string :user_id
      t.string :email
      t.boolean :is_disabled

      t.timestamps
    end
  end
end
