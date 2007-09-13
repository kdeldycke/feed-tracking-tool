class FeedController < ApplicationController

  # Default method to view a flat list of all feed in the database
  def index
  end

  # Method to add a new feed in the database
  def add
    feed = Feed.new(params[:feed])  # Creation of an entry in feed table
    if request.post?
      # We check if the entered feed already exists in the database
      ex = false
      Feed.find(:all).each do |r|
        if feed.url == r.url
          ex = true
        end
      end
      if ex == false  # If the feed doesn't exist in the database
        if feed.save       # If the form has been validated
          if rss(feed.url) == true # If the feed from the url entered in the form can be parsed
            feed.update_attribute :title , @title               # The title field is updated in the feed table
            feed.update_attribute :description, @description    # The description field is updated in the feed table
            feed.update_attribute :link, @link                  # The link field is updated in the feed table
            flash[:notice] = "New feed added. Articles from this feed will be fetched within the hour."
          else
            flash[:warning] = "Invalid URL !"
            feed.destroy
            feed.save
          end
        else
          flash[:warning] = "Invalid URL !"
          @feed = feed
        end
      else
        flash[:notice] = "This feed was already added to database."
      end
      redirect_to :controller => 'feed' # Go back to default feed view
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

  # Method that delete a feed from the database
  def delete
    feed = Feed.find(params[:id])   # Get the feed to delete
    if feed.trackers_count > 0
      flash[:warning] = "Can't remove feed as long as trackers are still using it."
    else
      feed.destroy
      feed.save
      flash[:notice] = "Feed removed !"
    end
    redirect_to :controller => 'feed' # Go back to default feed view
  end

end