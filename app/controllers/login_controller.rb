#require 'ldap_connect'
class LoginController < ApplicationController
  skip_before_filter :authenticate  # Permet l'accès à cette page sans être authentifié
  
  def index
    
  end
  
  # Authentification
#  def authenticate
#    if session[:person] = LDAP.authenticate(params[:login][:name], params[:login][:password])
#      session[:username] = params[:login][:name].capitalize_each
#      if session[:return_to]
#        redirect_to_path(session[:return_to])
#        session[:return_to] = nil
#      else
#        redirect_to :controller => "dashboard", :action => "dashboard"
#      end
#    else
#      flash[:notice] = "Echec de l'authentification!"
#      redirect_to :action => "index"
#    end
#  end
  
  def authenticate
    if request.post?
      session[:username] = params[:login][:name]
      Notifier.deliver_test_email(Profile.find_by_user_id(session[:username]).email)
      redirect_to :controller => "dashboard", :action => "display"
    end
  end
  
  # Logout
  # réinitialise la session
#  def logout
#    session[:person] = nil
#    session[:username] = nil
#    flash[:notice] = "Deconnecte"
#    redirect_to :action => "index"
#  end
  
  def logout
    session[:username] = nil
    flash[:notice] = "D&eacute;connect&eacute;"
    redirect_to :action => "index"
  end
  
  def profile
    
  end
  
end
