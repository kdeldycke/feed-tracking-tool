class ModifUserIdType < ActiveRecord::Migration
  def self.up
    remove_column :sent_article_archive, :user_id
    add_column :sent_article_archive, :user_id, :string
    remove_column :subscription, :user_id
    add_column :subscription, :user_id, :string
  end

  def self.down
    remove_column :sent_article_archive, :user_id
    add_column :sent_article_archive, :user_id, :integer
    remove_column :subscription, :user_id
    add_column :subscription, :user_id, :integer
  end
end
