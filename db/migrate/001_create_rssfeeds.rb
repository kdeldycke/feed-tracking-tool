class CreateRssfeeds < ActiveRecord::Migration
  def self.up
    create_table :rssfeed do |t|
      t.column :title, :string
      t.column :description, :string
      t.column :url, :string
      t.column :tracked, :boolean
    end
  end

  def self.down
    drop_table :rssfeed
  end
end
