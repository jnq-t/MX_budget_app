class AddMetadataToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :metadata, :string
  end
end
