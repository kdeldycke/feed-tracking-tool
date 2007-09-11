class RenameVisibilityColumn < ActiveRecord::Migration
  def self.up
    add_column :tracker, :profile_id, :integer
    remove_column :tracker, :visibility
  end

  def self.down
    add_column :tracker, :visibility, :string
    remove_column :tracker, :profile_id
  end
end
