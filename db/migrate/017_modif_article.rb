class ModifArticle < ActiveRecord::Migration
  def self.up
    add_column :article, :rssfeed_id, :integer
  end

  def self.down
    remove__column :article, :rssfeed_id
  end
end
