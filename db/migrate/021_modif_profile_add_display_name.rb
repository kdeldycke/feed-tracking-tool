class ModifProfileAddDisplayName < ActiveRecord::Migration
  def self.up
    add_column :profile, :display_name, :string
  end

  def self.down
    remove_column :profile, :display_name
  end
end
