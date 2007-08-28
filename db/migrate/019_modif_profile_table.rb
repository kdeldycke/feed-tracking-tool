class ModifProfileTable < ActiveRecord::Migration
  def self.up
    add_column :profile, :email_sending_activated, :boolean
  end

  def self.down
    remove_column :profile, :email_sending_activated
  end
end
