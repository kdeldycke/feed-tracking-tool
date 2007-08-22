class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profile do |t|
      t.column :user_id, :string
      t.column :email, :string
    end
  end

  def self.down
    drop_table :profile
  end
end
