# TODO: Possibility to select several feeds for a tracker
#       Possibility to modify (edit) a tracker
#       Regular expressions management (now only keywords are handled)

class TrackerController < ApplicationController

  def edit
    @tracker = Tracker.new(params[:tracker])  # Creation of a new entry in tracker table
    @feeds = Feed.find(:all)               # Gets RSS feeds in feed table
    @selected_feed = []                        # Used to get the selected feed

    if request.post? and @tracker.save
      # Calculate the tracker visibility
      visibility = params[:t][:visibility]
      if visibility == "private"
        @tracker.update_attribute :profile_id, session[:user][:profile_id]
      end
      # Link the selected feed with our tracker
      @selected_feed = params[:feed][:id]
      @tracker.update_attribute :feed_id, @selected_feed
      # Auto-subscribe to the tracker ?
      # TODO: use subscription model to validate forms data
      if params[:t][:subscribe].to_i > 0 and params[:t][:frequency]
        # TODO: Use subscription controller to create new subscription with riht date_last_mail
        subscription = Subscription.new( {:frequency => params[:t][:frequency],
                                          :tracker_id => @tracker.id,
                                          :profile_id => session[:user][:profile_id],
                                          :date_lastmail => (Time.now - (params[:t][:frequency].to_i*3600*24))}) # XXX Duplicate code with subscription controler
        subscription.save
      end
      flash[:notice] = "New tracker created."
      redirect_to :controller => 'tracker', :action => 'edit'     # Refreshing page
    end
  end

  # Method for removing a tracker
  def destroy
    t=Tracker.find(params[:id])   # Searching in database for the tracker to remove

    d = t.subscriptions_count   # We count the number of subscriptions to this tracker
    if d>0                      # If this number is positive, we can't remove the tracker
      flash[:warning] = "Other users are still using this tracker: you can't remove it !"
    else
      t.destroy                     # Destroying the tracker
      t.save
      flash[:notice] = 'Tracker deleted.'
    end
    redirect_to :controller => 'tracker', :action => 'edit'     # Refreshing page
  end

end