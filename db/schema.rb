# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 30) do

  create_table "article", :force => true do |t|
    t.column "title",            :string
    t.column "url",              :string
    t.column "description",      :text
    t.column "publication_date", :datetime
    t.column "fetch_date",       :datetime
    t.column "feed_id",          :integer
  end

  create_table "article_to_send", :force => true do |t|
    t.column "article_id", :integer
    t.column "tracker_id", :integer
    t.column "profile_id", :integer
  end

  create_table "feed", :force => true do |t|
    t.column "title",       :string
    t.column "description", :text
    t.column "url",         :string
    t.column "link",        :string
  end

  create_table "profile", :force => true do |t|
    t.column "user_id",           :string
    t.column "email",             :string
    t.column "suspend_email",     :boolean
    t.column "display_name",      :string
    t.column "default_frequency", :integer, :default => 1
  end

  create_table "sent_article_archive", :force => true do |t|
    t.column "article_id",   :integer
    t.column "sending_date", :datetime
    t.column "profile_id",   :integer
  end

  create_table "subscription", :force => true do |t|
    t.column "tracker_id",    :integer
    t.column "date_lastmail", :datetime
    t.column "frequency",     :integer
    t.column "profile_id",    :integer
  end

  create_table "tracked_article", :force => true do |t|
    t.column "article_id", :integer
    t.column "tracker_id", :integer
  end

  create_table "tracker", :force => true do |t|
    t.column "regex",      :string
    t.column "title",      :string
    t.column "feed_id",    :integer
    t.column "profile_id", :integer
  end

end
