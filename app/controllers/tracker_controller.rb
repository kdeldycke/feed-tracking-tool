# TODO: Possibility to select several feeds for a tracker
#       Possibility to select all current (and future) feed to track
#       Possibility to modify (edit) a tracker
#       Regular expressions management (now only keywords are handled)

class TrackerController < ApplicationController

  def index
  end

  def add
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
      redirect_to :controller => 'tracker'  # Go back to default view
    end
  end

  # Method to subscribe directly to a tracker
  def subscribe
    tracker = Tracker.find(params[:id])
    if not tracker.blank?
      profile = Profile.find(session[:user][:profile_id])
      if Subscription.find(:all, :conditions => {:profile_id => profile.id, :tracker_id => tracker.id}).size > 0
        flash[:warning] = "You already subscribed to the tracker."
      else
        subscription = Subscription.new( {:frequency =>  profile.default_frequency,
                                          :tracker_id => tracker.id,
                                          :profile_id => profile.id,
                                          :date_lastmail => (Time.now - (profile.default_frequency.to_i*3600*24))}) # XXX Duplicate code with subscription controler
        subscription.save
        flash[:notice] = "Tracker subscribed !"
      end
    end
    redirect_to :controller => 'tracker'  # Go back to default view
  end

  # Method that delete a feed from the database
  def delete
    tracker = Tracker.find(params[:id])
    if tracker.subscriptions_count > 0
      flash[:warning] = "Can't delete tracker as long as users are still using it."
    else
      tracker.destroy
      tracker.save
      flash[:notice] = "Tracker deleted !"
    end
    redirect_to :controller => 'tracker'  # Go back to default view
  end

end