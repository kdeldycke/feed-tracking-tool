class CreateTrackers < ActiveRecord::Migration
  def self.up
    create_table :tracker do |t|
      t.column :feed_id, :integer
      t.column :regex, :string
      t.column :title, :string
      t.column :type, :string
    end
  end

  def self.down
    drop_table :tracker
  end
end
