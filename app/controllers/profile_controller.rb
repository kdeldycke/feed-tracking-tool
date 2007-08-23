class ProfileController < ApplicationController


  def index
    # Get the currrent user profile or create a new one if doesn't exist
    user_id = session[:username]
    profile = Profile.find_by_user_id(user_id)
    if not profile:
      profile = Profile.new
      profile.user_id = user_id
    end

    # Was the form submitted ?
    if request.post?
      # Save user new email in new profile
      profile.email = params[:profile][:email]
      # Try to save the new profile in the database
      if profile.save
        flash[:notice] = 'Preferences updated'
      # Database save failed, new profile data don't fit in the model.
      else
        # TODO: get error message from the profile model constraint definition
        flash[:warning] = 'Invalid email address !'
      end
      # Redirect to controller default action
      redirect_to :controller => 'profile'

    # "View" mode, use current profile as instance variable
    else
      @profile = profile
    end
  end


end