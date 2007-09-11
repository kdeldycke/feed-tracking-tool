class RssfeedController < ApplicationController

  # TODO: Rename table 'rssfeed' in 'feed' (or a more generic name)

  def manage
    rssfeed = Rssfeed.new(params[:rssfeed])  # Creation of an entry in rssfeed table
    if request.post?
      # We check if the entered feed already exists in the database
      ex = false
      Rssfeed.find(:all).each do |r|
        if rssfeed.url == r.url
          ex = true
        end
      end
      if ex == false  # If the feed doesn't exist in the database
        if rssfeed.save       # If the form has been validated
          if rss(rssfeed.url) == true # If the feed from the url entered in the form can be parsed
            rssfeed.update_attribute :title , @title               # The title field is updated in the rssfeed table
            rssfeed.update_attribute :description, @description    # The description field is updated in the rssfeed table
            rssfeed.update_attribute :link, @link                  # The link field is updated in the rssfeed table
            flash[:notice] = "New feed added. Articles from this feed will be fetched within the hour. You can track this feed in 'Trackers' panel."
          else
            flash[:warning] = "Invalid URL!"
            rssfeed.destroy
            rssfeed.save
          end
        else
          flash[:warning] = "Invalid URL!"
          @rssfeed = rssfeed
        end
      else
        flash[:warning] = "This feed already exists in FTT public feeds."
      end
      redirect_to :controller => 'rssfeed', :action => 'manage' # Refreshing page
    end
  end

  # Method for parsing an RSS feed, using the FeedTools parser
  def rss(url)
    ret = false
    feed = FeedTools::Feed.open(url)  # Creation of an instance of FeedTools and opening of the feed
    # If the parsing return nil title field, we consider the feed not valid
    unless feed.title.nil?
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
      flash[:warning] = "Some trackers are still using the feed as content source: you can't remove it."
    else
      r.destroy                     # Destroying the feed
      r.save
      flash[:notice] = 'Feed removed successfully!'
    end
    redirect_to :controller => 'rssfeed', :action => 'manage' # Refreshing page
  end

end
