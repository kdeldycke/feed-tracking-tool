# TODO: Frequency could be counted in hours instead of days (or just more flexible)
#       -> possibility to subscribe with an option like 'receive a mail when new articles available'

class SubscriptionController < ApplicationController

  def manage
    @subscription = Subscription.new(params[:subscription])  # Creation of an entry in subscription table
    @trackers = Tracker.find(:all)            # Gets all trackers in tracker table
    @selected_tracker = []                    # Used to get the selected tracker

    if request.post? and @subscription.save
      @selected_tracker = params[:tracker][:id]                         # We get the selected tracker
      @subscription.update_attribute :tracker_id, @selected_tracker     # Update of tracker_id field in tracker table
      @subscription.update_attribute :user_id, session[:user][:id]
      @subscription.update_attribute :date_lastmail, Time.now-@subscription.frequency.day
      flash[:notice] = 'Subscription added successfully. You will receive your first email within the hour (unless you deactivate email notification in your profile).'
      redirect_to :controller => 'subscription', :action => 'manage'    # Refreshing page
    end
  end

  # Deleting subscription
  def destroy
    s=Subscription.find(params[:id])   # Searching in database for the subscription to remove
    s.destroy                     # Destroying the subscription
    s.save
    flash[:notice] = 'Subscription cancelled'
    redirect_to :controller => 'subscription', :action => 'manage'     # Refreshing page
  end


  def trackers
    @trackers = Subscription.find(:all, :select => 'DISTINCT tracker_id' )  # Gets list of trackers in subscription table
  end

end