# TODO: test https:// and feed:// feeds !


class FeedController < ApplicationController


  # Default method to view a flat list of all feed in the database
  def index
  end


  # Method to add a new feed in the database
  def add
    if request.post?
      feed = Feed.new(params[:feed])  # Create a temporary local feed

      if feed.valid?  # True if object respect model constraints
#         begin
          f = FeedTools::Feed.open(feed.url)  # Let FeedTools try to do its best to get the feed
#         rescue FeedTools::FeedAccessError => e
#   # This is temporary code that must ensure that page using https protocol are considered as a static page
#           e.message
#
#         end

        # While pending, use feed.url as temporary title. The feed fetcher will update the title.
        feed.title = feed.url
        # As above, use a temporary descriptive description.
        feed.description = "This feed will be fetched in less than 10 minutes."

        # If FeedTools guess the feed type it means that the remote document is really a feed
        if f.feed_type
          # Perform here actions specific to true feeds...
          feed.feed_type = f.feed_type
          # Force feed URL update because sometimes FeedTool is able to found the feed embedded in a static page automaticaly.
          feed.url = f.url
        # URL is not pointing to something that look like a feed.
        else
          # Consider the document a static page
          feed.feed_type = "static"
        end

        # Do not set feed.fetch_date: the feed fetcher will fetch the feed as soon as possible when its fetch_date value is NULL

        # Save Object
        feed.save

        # Do not add a feed that already exist in database
        if Feed.find(:all, :conditions => {:url => feed.url(bypass_dynamic_translation = true)}).size > 0
          flash[:notice] = "This feed was already added to database."
        else
          flash[:notice] = "New feed added. It will be fetched in less than 10 minutes."
        end

      else
        flash[:warning] = "Invalid URL !"
        @feed = feed # TODO: Isn't it what should be done to get back all user input when we redirect to the form ? If so, why it doesn't work as expected ?
      end

      # Redirect to the right place
      if flash[:warning]
        redirect_to :controller => 'feed', :action => 'add'
      else
        redirect_to :controller => 'feed' # Go back to default feed view
      end

    end
  end


  # Method that wrap a static page in a feed
  # Ex: to feedalize the google home page, go to http://www.mydomain.com/feedalize/http://www.google.com
  def feedalize
    require 'feedalizer_tool'

    # Trick required to let RoR parse URLs with options given as parameter in routes
    self.rebuild_dynamic_parameters

    # Build the feed
    feed_data = FeedalizerTools.get_feed_from_static_page(@uri)

    # Render the feed
    if feed_data.blank?
      flash[:warning] = "No page given to feedalize !"
      redirect_to :controller => 'feed'
    else
      render :text => feed_data, :content_type => "application/rss+xml"
    end
  end


  # TODO: XML interface ??
  #        render :xml => Feed.find(:all).to_xml


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


protected

  # When a source URL is given to the feedalize action as a parameter,
  #  this method help us to keep the entire URL intact while taking care of
  #  trailing options (like "?foo=bar&option") that RoR ignore by default.
  # Based on http://www.igvita.com/blog/2007/07/31/reconstructing-request-uris-in-rails/
  def rebuild_dynamic_parameters
    # assuming the route with /.*/ match is present, and points to :source
    @uri = params[:source]
    # omit true Rails query parameters, and append the rest back to the URI
    query_string = params.select {|k,v| not %w[action controller source].include?(k)}
    unless query_string.empty?
      query_params = query_string.collect {|k,v| "#{k}=#{v}"}
      logger.info "!!!parameter trick: " + query_params.inspect
      @uri << "?" << query_params.join("&")
    end
  end

end