class RenameRssFeedTableToFeed < ActiveRecord::Migration
  def self.up
    rename_table :rssfeed, :feed
    rename_column :article, :rssfeed_id, :feed_id
    rename_column :tracker, :rssfeed_id, :feed_id
  end

  def self.down
    rename_table :feed, :rssfeed
    rename_column :article, :feed_id, :rssfeed_id
    rename_column :tracker, :feed_id, :rssfeed_id
  end
end
