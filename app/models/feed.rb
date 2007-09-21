class Feed < ActiveRecord::Base

  has_many :trackers

  # Feed URL is a lind of a primary key
  # TODO: should be names "URI" as this acronym reflect the true unique nature of feed access path
  validates_presence_of :url
  validates_uniqueness_of :url

  # Inspired by http://www.nshb.net/node/252
  # We should use a combination of FeedTools nomalize method (which take care of URL of the rss:// and feed:// form) and http://www.igvita.com/blog/2006/09/07/validating-url-in-ruby-on-rails/
  # As you can see in feed_tools/feed.rb at line 302, FeedTools doesn't support yet https:// and ftp:// protocol. OTOH, we don't whant to allow parsing of local files (via the file:// protocol). So the regexp below only accept http:// URLs.
#   validates_format_of :url,
#                       :with => /^http:\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix,
#                       :message => "Malformated URL."


  # Tiny method to make our life easier ! :)
  def is_static?
    if self[:feed_type] == "static"
      return true
    end
    return false
  end

  # A feed in a pending state is a feed that was just added by the user and was not yet fetched yet
  def is_pending?
    if self[:fetch_date].blank?
      return true
    end
    return false
  end

  # Return a keyword that give the current status of the feed
  def state
    if self.is_pending?
      return "pending"
    elsif self[:feed_type].blank?
      return "unknown"
    end
    return self[:feed_type]
  end

  # Override default url getter to use our internal feedalizer tool to transform the static page to a feed.
  # We can still get the true url thanks to the bypass_dynamic_translation parameter.
  def url(bypass_dynamic_translation=false)
    url = self[:url]
    if (not bypass_dynamic_translation) and self[:feed_type] == "static"
      return "#{FTT_PUBLIC_URL}/feedalize/#{url}"
    else
      return url
    end
  end

end
