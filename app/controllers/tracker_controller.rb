# TODO: Private trackers
#       Possibility to select several feeds for a tracker
#       Possibility to modify (edit) a tracker
#       Regular expressions management (now only keywords are handled)

class TrackerController < ApplicationController

  def edit
    @tracker = Tracker.new(params[:tracker])  # Creation of a new entry in tracker table
    @feeds = Rssfeed.find(:all)               # Gets RSS feeds in rssfeed table
    @selected_feed = []                        # Used to get the selected feed

    if request.post? and @tracker.save
      # Calculate the tracker visibility
      visibility = params[:t][:visibility]
      if visibility == "private"
        @tracker.update_attribute :profile_id, session[:user][:profile_id]
      end
      # Link the selected feed with our tracker
      @selected_feed = params[:rssfeed][:id]
      @tracker.update_attribute :rssfeed_id, @selected_feed          # Update of feed_id field in rssfeed table
      flash[:notice] = "Tracker added successfully. You can subscribe to this tracker through 'My Trackers'."
      redirect_to :controller => 'tracker', :action => 'edit'     # Refreshing page
    end
  end

  # Method for removing a tracker
  def destroy
    t=Tracker.find(params[:id])   # Searching in database for the tracker to remove

    d = t.subscriptions_count   # We count the number of subscriptions to this tracker
    if d>0                      # If this number is positive, we can't remove the tracker
      flash[:warning] = 'One or more users have subscribed to this tracker : Removing it is forbidden until subscription(s) exists.'
    else
      t.destroy                     # Destroying the tracker
      t.save
      flash[:notice] = 'Tracker deleted successfully!'
    end
    redirect_to :controller => 'tracker', :action => 'edit'     # Refreshing page
  end

end

# TODO: User must be able to modify a tracker