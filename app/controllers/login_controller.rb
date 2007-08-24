require 'ldap_connect'
class LoginController < ApplicationController
  skip_before_filter :authenticate  # Permet l'acc�s � cette page sans �tre authentifi�

  def authenticate
    # Inspired by http://www.rich-waters.com/blog/2007/02/using-domino-logins-ldap-for-a-ruby-on-rails-app.html
    auth_result = LDAP.authenticate(params[:login][:name], params[:login][:password])
    if auth_result[:authenticated]
      session[:user] = {:login        => params[:login][:name],
                        :id           => LDAP.generateDNFromLogin(params[:login][:name]),
                        :display_name => params[:login][:name], # TODO: get display_name from LDAP
                       }
      if session[:return_to]
        redirect_to_path(session[:return_to])
        session[:return_to] = nil
      else
        redirect_to :controller => "dashboard", :action => "display"
      end
    else
      flash[:warning] = auth_result[:message]
      redirect_to :action => "index"
    end
  end

  # Logout
  # r�initialise la session
  def logout
    session[:user] = nil
    flash[:notice] = "Deconnecte"
    redirect_to :action => "index"
  end

end