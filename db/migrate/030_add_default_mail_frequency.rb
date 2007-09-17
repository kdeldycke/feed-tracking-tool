class AddDefaultMailFrequency < ActiveRecord::Migration
  def self.up
    add_column :profile, :default_frequency, :integer, {:default => 1}
  end

  def self.down
    remove_column :profile, :default_frequency
  end
end
