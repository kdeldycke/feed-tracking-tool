require 'ldap_connect'


class LoginController < ApplicationController
  skip_before_filter :authenticate   # This page is public

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

      # Create new profile if first login (= no user found in database), else load user profile
      profile = Profile.find_by_user_id(dn)
      if not profile:
        profile = Profile.new
        profile.update_attribute :user_id, dn
      end

      # Initialize each user preference if first login
      if profile.suspend_email.blank?
        # Activate email sending by default. If the user receive mails he don't want, a message in each email footer remind him how to disable automatic mail sending.
        profile.update_attribute :suspend_email, false
      end

      # Do we need a LDAP request to get more details ?
      if profile.email.blank? or profile.display_name.blank?
        user_details = LDAP.getAttributeList(login, pwd)   # get all user LDAP details
        if profile.email.blank?
          profile.update_attribute :email, user_details[:mail]
        end
        if profile.display_name.blank?
          profile.update_attribute :display_name, user_details[:displayname]
        end
      end

      # Register user in the session
      session[:user] = {:login        => login,
                        :id           => dn,
                        :display_name => Profile.find_by_user_id(dn).display_name
                       }

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
    flash[:notice] = "Logged out"
    redirect_to :action => "index"
  end

end