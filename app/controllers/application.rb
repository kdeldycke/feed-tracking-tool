# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  ####session :session_key => '_OVT_session_id'
  before_filter :authenticate
  filter_parameter_logging "password"

  protected
  def authenticate
    unless session[:username]
      session[:return_to] = @request.request_uri
      redirect_to :controller => "login"
      return false
    end
  end

end
