class DeleteUselessTrackedColumn < ActiveRecord::Migration
  def self.up
    remove_column :rssfeed, :tracked
  end

  def self.down
    add_column :rssfeed, :tracked, :boolean
  end
end
