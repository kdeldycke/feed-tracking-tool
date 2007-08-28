require 'ldap_connect'


class LoginController < ApplicationController
  skip_before_filter :authenticate  # This page is public

  def index
    # Redirect to dashboard if user logged in
    if session[:user]
      redirect_to :controller => 'dashboard', :action => "display"
    end
  end

  def authenticate
    # Inspired by http://www.rich-waters.com/blog/2007/02/using-domino-logins-ldap-for-a-ruby-on-rails-app.html
    login = params[:login][:name]
    pwd   = params[:login][:password]
    dn    = LDAP.generateDNFromLogin(login)
    auth_result = LDAP.authenticateByDN(dn, pwd)
    if auth_result[:authenticated]
      user_details = LDAP.getAttributeList(login, pwd)
      session[:user] = {:login        => login,
                        :id           => dn,
                        :display_name => user_details[:displayname],
                       }
      # Create new profile and update default mail if necessary
      profile = Profile.find_by_user_id(dn)
      if not profile:
        profile = Profile.new
        profile.update_attribute :user_id, dn
      end
      if profile.email.blank?
        profile.update_attribute :email, user_details[:mail]
      end
      if profile.suspend_email.blank?
        # Activate email sending by default. If the user receive mails he don't want, a message in each email footer remind him how to disable automatic mail sending.
        profile.update_attribute :suspend_email, false
      end
      if profile.display_name.blank?
        # TODO: do not get display_name or email adress from the LDAP if not empty
        profile.update_attribute :display_name, user_details[:displayname]
      end
      # Redirect to the right place
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


  def logout
    # Reset session
    session[:user] = nil
    flash[:notice] = "Deconnecte"
    redirect_to :action => "index"
  end

end