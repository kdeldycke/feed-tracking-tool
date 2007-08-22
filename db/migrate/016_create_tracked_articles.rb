class CreateTrackedArticles < ActiveRecord::Migration
  def self.up
    create_table :tracked_article do |t|
      t.column :article_id, :integer
      t.column :tracker_id, :integer
    end
    remove_column :article, :tracker_id
  end

  def self.down
    drop_table :tracked_article
    add_column :article, :tracker_id, :integer
  end
end
