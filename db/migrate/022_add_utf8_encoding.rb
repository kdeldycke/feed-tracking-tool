class AddUtf8Encoding < ActiveRecord::Migration
  def self.up
    execute("ALTER TABLE article MODIFY title varchar(255) character set utf8;")
    execute("ALTER TABLE article MODIFY url varchar(255) character set utf8;")
    execute("ALTER TABLE article MODIFY content varchar(255) character set utf8;")
    
    execute("ALTER TABLE article_to_send MODIFY user_id varchar(255) character set utf8;")
    
    execute("ALTER TABLE profile MODIFY user_id varchar(255) character set utf8;")
    execute("ALTER TABLE profile MODIFY email varchar(255) character set utf8;")
    execute("ALTER TABLE profile MODIFY dislpay_name varchar(255) character set utf8;")
    
    execute("ALTER TABLE rssfeed MODIFY title varchar(255) character set utf8;")
    execute("ALTER TABLE rssfeed MODIFY description varchar(255) character set utf8;")
    execute("ALTER TABLE rssfeed MODIFY url varchar(255) character set utf8;")
    execute("ALTER TABLE rssfeed MODIFY link varchar(255) character set utf8;")
    
    execute("ALTER TABLE sent_article_archive MODIFY user_id varchar(255) character set utf8;")
    
    execute("ALTER TABLE subscription MODIFY user_id varchar(255) character set utf8;")
    
    execute("ALTER TABLE tracker MODIFY regex varchar(255) character set utf8;")
    execute("ALTER TABLE tracker MODIFY title varchar(255) character set utf8;")
    execute("ALTER TABLE tracker MODIFY type varchar(255) character set utf8;")
  end

  def self.down
  end
end
