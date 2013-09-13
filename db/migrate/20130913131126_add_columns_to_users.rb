class AddColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :uid, :string
    add_column :users, :name, :string
    add_column :users, :access_token, :string
    add_column :users, :access_token_secret, :string
  end
end
