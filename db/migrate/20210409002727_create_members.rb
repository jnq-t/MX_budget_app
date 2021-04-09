class CreateMembers < ActiveRecord::Migration[6.1]
  def change
    create_table :members do |t|
      t.string :guid
      t.string :member_id
      t.string :user_guid
      t.string :aggregated_at
      t.string :institution_code
      t.string :is_being_aggregated
      t.boolean :is_oauth
      t.string :metadata
      t.string :name
      t.string :successfully_aggregated_at

      t.timestamps
    end
  end
end
