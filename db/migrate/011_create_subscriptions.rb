class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscription do |t|
      t.column :user_id, :integer
      t.column :tracker_id, :integer
      t.column :date_lastmail, :datetime
      t.column :frequency, :integer
    end
    drop_table :mail_frequency
  end

  def self.down
    drop_table :subscription
  end
end
