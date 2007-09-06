class DeleteTrackerType < ActiveRecord::Migration
  def self.up
    remove_column :tracker, :type
  end

  def self.down
    add_column :tracker, :type, :string
  end
end
