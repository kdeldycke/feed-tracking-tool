class ModifProfileEmailActivationName < ActiveRecord::Migration
  def self.up
    remove_column :profile, :email_sending_activated
    add_column :profile, :suspend_email, :boolean
  end

  def self.down
    add_column :profile, :email_sending_activated, :boolean
    remove_column :profile, :suspend_email
  end
end
