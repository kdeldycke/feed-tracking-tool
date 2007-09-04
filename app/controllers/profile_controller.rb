class ProfileController < ApplicationController

  def edit
    # Get the currrent user profile or create a new one if doesn't exist
    # XXX Duplicate code with the one which exist in the login_controller !
    user_id = session[:user][:id]
    profile = Profile.find_by_user_id(user_id)
    if not profile:
      profile = Profile.new
      profile.user_id = user_id
    end

    # Was the form submitted ?
    if request.post?
      # Save user new preferences in new profile
      profile.email = params[:profile][:email]
      profile.suspend_email = params[:profile][:suspend_email]
      profile.display_name = params[:profile][:display_name]
      # TODO: if one of the variable is empty, get LDAP default value like login_controller do. If so, warn the user with this following message: flash[:notice] = 'Preferences updated. Display name resetted to LDAP default.' I think all this stuff must be generic enough to not repeat ourselves and to be put in profile_helper...
      # Try to save the new profile in the database
      if profile.save
        flash[:notice] = 'Preferences updated'
        # Update session with new user's dispay_name
        session[:user][:display_name] = profile.display_name
      # Database save failed, new profile data do not respect model data constraint.
      else
        # TODO: get error message from the profile model constraint definition
        flash[:warning] = 'Invalid email address !'
      end
      # Redirect to controller default action
      redirect_to :controller => 'profile', :action => 'edit'

    # "View" mode, use current profile as instance variable
    else
      @profile = profile
    end
  end


  def users
    @users = Subscription.find(:all, :select => 'DISTINCT user_id')  # Gets list of users in subscription table
  end

end