class AddTrackerVisibility < ActiveRecord::Migration
  def self.up
    add_column :tracker, :visibility, :string
  end

  def self.down
    remove_column :tracker, :visibility
  end
end