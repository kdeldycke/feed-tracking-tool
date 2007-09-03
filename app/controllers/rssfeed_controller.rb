class RssfeedController < ApplicationController

  def manage
    rssfeed = Rssfeed.new(params[:rssfeed])  # Creation of an entry in rssfeed table
    if request.post?
      if rss(rssfeed.url) == true # If the feed from the url entered in the form can be parsed
        if rssfeed.save       # If the form has been validated
          rssfeed.update_attribute :title , @title               # The title field is updated in the rssfeed table
          rssfeed.update_attribute :description, @description    # The description field is updated in the rssfeed table
          rssfeed.update_attribute :link, @link                  # The link field is updated in the rssfeed table
          flash[:notice] = "RSS feed added successfully. This feed will be taken into account within the hour."
        end
      else
        flash[:warning] = "Invalid URL!"
        @rssfeed = rssfeed
      end
      redirect_to :controller => 'rssfeed', :action => 'manage' # Refreshing page
    end
  end

  # Method for parsing an RSS feed, using the FeedTools parser
  def rss(url)
    ret = false
    feed = FeedTools::Feed.open(url)  # Creation of an instance of FeedTools and opening of the feed
    # If the parsing return nil fields, the feed is not valid
    unless feed.title.nil? and feed.description.nil? and feed.link.nil?
      @title       = feed.title        # We get the title field and convert it to unicode if needed
      @description = feed.description  # We get the description field and convert it to unicode if needed
      @link        = feed.link         # We get the link field
      ret = true        # The return value is set to true (the field is valid)
    end
    return ret
  end

  # Method for removing a feed from the database
  def destroy
    r = Rssfeed.find(params[:id])   # Searching in the database of the feed to remove

    d = r.trackers_count        # We count the number of trackers associated to this feed
    if d>0                      # If this number is positive, we can't remove the RSS feed
      flash[:warning] = 'RSS feed used in one ore more trackers : Removing it is forbidden until tracker(s) exists.'
    else
      r.destroy                     # Destroying the feed
      r.save
      flash[:notice] = 'RSS feed removed successfully!'
    end
    redirect_to :controller => 'rssfeed', :action => 'manage' # Refreshing page
  end

end
