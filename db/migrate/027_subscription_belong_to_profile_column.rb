class SubscriptionBelongToProfileColumn < ActiveRecord::Migration
  def self.up
    add_column :subscription, :profile_id, :integer
    remove_column :subscription, :user_id
  end

  def self.down
    remove_column :subscription, :profile_id
    add_column :subscription, :user_id, :string
  end
end
