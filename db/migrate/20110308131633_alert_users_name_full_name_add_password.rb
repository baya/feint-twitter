class AlertUsersNameFullNameAddPassword < ActiveRecord::Migration
  def self.up
    rename_column :users, :name, :full_name
    rename_column :users, :login, :password
  end

  def self.down
    rename_column :users, :full_name, :name
    rename_column :users, :password, :login
  end
end
