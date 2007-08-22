class DestroyUsers < ActiveRecord::Migration
  def self.up
    drop_table :user
  end

  def self.down
    create_table :user do |t|
      t.column :login, :string
      t.column :password, :string
      t.column :name, :string
      t.column :email, :string
    end
  end
end
