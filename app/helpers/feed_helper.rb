module FeedHelper

  # Method that return a pretty formatted string that tell in which status the feed is
  def pretty_state(feed)
    if feed.is_pending? or feed.is_static?
      return feed.state.capitalize
    end
    return feed.state.upcase
  end

end
