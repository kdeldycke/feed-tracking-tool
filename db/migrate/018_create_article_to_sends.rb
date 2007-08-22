class CreateArticleToSends < ActiveRecord::Migration
  def self.up
    create_table :article_to_send do |t|
      t.column :article_id, :integer
      t.column :tracker_id, :integer
      t.column :user_id, :string
    end
  end

  def self.down
    drop_table :article_to_send
  end
end
