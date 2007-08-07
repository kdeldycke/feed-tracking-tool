class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :user do |t|
      t.column :login, :string
      t.column :password, :string
      t.column :name, :string
      t.column :email, :string
    end
  end

  def self.down
    drop_table :user
  end
end
