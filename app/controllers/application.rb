# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  ####session :session_key => '_OVT_session_id'
  before_filter :authenticate
  filter_parameter_logging "password"

  before_filter :set_charset
  
  def set_charset
    suppress(ActiveRecord::StatementInvalid) do
      ActiveRecord::Base.connection.execute 'SET NAMES UTF8'
    end

    if request.xhr?
      @headers['Content-Type'] = 'text/javascript; charset=utf-8'
    else
      @headers['Content-Type'] = 'text/html; charset=utf-8'
    end
  end

  protected
  def authenticate
    unless session[:user]
      session[:return_to] = @request.request_uri
      redirect_to :controller => "login"
      return false
    end
  end

end
