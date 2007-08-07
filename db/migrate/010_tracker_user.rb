class TrackerUser < ActiveRecord::Migration
  def self.up
    create_table :tracker_user, :id => false do |t|
        t.column :tracker_id, :integer
        t.column :user_id, :integer
    end
  end

  def self.down
    drop_table :tracker_user
  end
end
