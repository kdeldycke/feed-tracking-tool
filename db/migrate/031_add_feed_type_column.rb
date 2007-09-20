class AddFeedTypeColumn < ActiveRecord::Migration
  def self.up
    add_column :feed, :feed_type, :string
  end

  def self.down
    remove_column :feed, :feed_type
  end
end
