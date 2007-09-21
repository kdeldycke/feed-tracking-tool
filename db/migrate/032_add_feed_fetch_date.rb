class AddFeedFetchDate < ActiveRecord::Migration
  def self.up
    add_column :feed, :fetch_date, :datetime
  end

  def self.down
    remove_column :feed, :fetch_date
  end
end
