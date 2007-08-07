class CreateSentArticleArchives < ActiveRecord::Migration
  def self.up
    create_table :sent_article_archive do |t|
      t.column :user_id, :integer
      t.column :article_id, :integer
      t.column :sending_date, :datetime
    end
  end

  def self.down
    drop_table :sent_article_archive
  end
end
