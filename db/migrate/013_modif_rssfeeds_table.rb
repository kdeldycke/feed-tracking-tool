class ModifRssfeedsTable < ActiveRecord::Migration
  def self.up
    add_column :rssfeed, :link, :string
  end

  def self.down
    remove_column :rssfeed, :link
  end
end
