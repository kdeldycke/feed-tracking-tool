class Rssfeed < ActiveRecord::Base
  has_many :trackers
  # Inspired by http://www.nshb.net/node/252

  # We should use a combination of FeedTools nomalize method (which take care of URL of the rss:// and feed:// form) and http://www.igvita.com/blog/2006/09/07/validating-url-in-ruby-on-rails/

  # As you can see in feed_tools/feed.rb at line 302, FeedTools doesn't support yet https:// and ftp:// protocol. OTOH, we don't whant to allow parsing of local files (via the file:// protocol). So the regexp below only accept http:// URLs.
  validates_format_of :url,
                      :with => /^http:\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix,
                      :message => "Malformated URL."
end
