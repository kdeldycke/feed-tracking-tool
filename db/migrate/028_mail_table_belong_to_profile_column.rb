class MailTableBelongToProfileColumn < ActiveRecord::Migration
  def self.up
    add_column    :sent_article_archive, :profile_id, :integer
    remove_column :sent_article_archive, :user_id
    add_column    :article_to_send, :profile_id, :integer
    remove_column :article_to_send, :user_id
  end

  def self.down
    remove_column :sent_article_archive, :profile_id
    add_column    :sent_article_archive, :user_id, :string
    remove_column :article_to_send, :profile_id
    add_column    :article_to_send, :user_id, :string
  end
end
