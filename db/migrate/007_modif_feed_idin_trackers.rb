class ModifFeedIdinTrackers < ActiveRecord::Migration
  def self.up
    remove_column :tracker, :feed_id
    add_column :tracker, :rssfeed_id, :integer
  end

  def self.down
    remove_column :tracker, :rssfeed_id
    add_column :tracker, :feed_id, :integer
  end
end
