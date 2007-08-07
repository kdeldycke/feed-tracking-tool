class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :article do |t|
      t.column :tracker_id, :integer
      t.column :title, :string
      t.column :url, :string
      t.column :content, :text
      t.column :publication_date, :datetime
      t.column :fetch_date, :datetime
      t.column :sent_flag, :boolean
    end
  end

  def self.down
    drop_table :article
  end
end
