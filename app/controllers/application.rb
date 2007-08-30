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
  
  # TEMPORARY method that converts a latin1 special sequency of characters to utf-8
  def convert_unicode(str)
    # Table containing special characters sequencies that need to be converted to utf-8
    latin = ["\351",  # é
             "\350",  # è
             "\340",  # à
             "\342",  # â
             "\344",  # ä
             "\346",  # ae
             "\347",  # ç
             "\352",  # ê
             "\353",  # ë
             "\356",  # î
             "\357",  # ï
             "\364",  # ô
             "\371"]  # ù
             
    i=0
    # For each item of the table
    while i < latin.nitems
      if str.include? latin[i]    # if the string includes a special character
        str = Iconv.new('utf-8', 'latin1').iconv(str) # we use the Iconv method to convert from latin1 to utf-8
        break # if the string contains at least one special character, it will whole be converted, so we don't need to do further testing
      end
      i+=1
    end
    return str
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
