class Rssfeed < ActiveRecord::Base
  has_many :trackers
  # Inspired by http://www.nshb.net/node/252
  # We should use a combination of FeedTools nomalize method (which take care of URL of the rss:// and feed:// form) and http://www.igvita.com/blog/2006/09/07/validating-url-in-ruby-on-rails/
  validates_format_of :url,
                      :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix, # Only accept http(s) URLs
                      :message => "invalid."
end
