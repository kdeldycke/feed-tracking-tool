# Inspired by http://www.rich-waters.com/blog/2007/02/using-domino-logins-ldap-for-a-ruby-on-rails-app.html

require 'net/ldap'

module LDAP

  def self.generateDNFromLogin(login)
    # This method generate a DN (= primary key for LDAP) from a login.
    # XXX This method will evolve in the future to handle multiple container much smarter.
    if login.length == 0
      return false
    end
    return "uid=#{login},ou=users,dc=uperto"
  end

  def self.authenticate(login, password)
    # This method is a simple wrapper to authenticate() that take a login as first parameter instead of a DN
    return self.authenticateByDN(self.generateDNFromLogin(login), password)
  end

  def self.authenticateByDN(dn, password)
    # Init default returned hash
    result = {:authenticated => false, :message => nil}

    # Check login and password
    if dn.length == 0
      result[:message] = "No login"
      return result
    elsif password.length == 0
      result[:message] = "No password"
      return result
    end

    # Setup the LDAP connection
      ldap_con = Net::LDAP.new({:host => '12.34.56.78',
                                :port => 389,
                                :base => "dc=uperto",
                                :auth => {:method   => :simple,
                                          :username => dn,
                                          :password => password,
                              }})

    # Connect to server
    begin
      ldap_con.bind
    rescue => e
      result[:msg] = e.message
      return result
    end

    con_result = ldap_con.get_operation_result
    if con_result.code != 0
      result[:message] = "LDAP error ##{con_result.code}: #{con_result.message}"
      return result
    end

    # User authenticated !
    result[:authenticated] = true
    result[:message] = con_result.message
    return result
  end

end