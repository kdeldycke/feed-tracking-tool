require 'net/ldap'


module LDAP

  # LDAP config
  HOST = "12.34.56.78"
  PORT = 389
  BASE = "ou=users,dc=uperto"


  def self.getLDAPConnection(dn, password)
    # Simple method to create a LDAP connection based on global config defined via constants above
    return Net::LDAP.new({:host => HOST,
                          :port => PORT,
                          :base => BASE,
                          :auth => {:method   => :simple,
                                    :username => dn,
                                    :password => password,
                          }})
  end


  def self.generateDNFromLogin(login)
    # This method generate a DN (= primary key for LDAP) from a login.
    # XXX This method will evolve in the future to handle multiple container much smarter.
    if login.length == 0
      return false
    end
    return "uid=#{login},#{BASE}" # XXX Ugly: hard coded. Should be at least defined in a constant
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

    # Connect to server
    ldap_con = self.getLDAPConnection(dn, password)
    begin
      ldap_con.bind
    rescue Exception => e
      result[:msg] = e.class.to_s + " - " + e.message.to_s
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


  def self.getAttributeList(uid, password)
    # Get all user's attributes
    # XXX This method is not bullet-proof. See comments for details...
    dn = self.generateDNFromLogin(uid)
    ldap_con = self.getLDAPConnection(dn, password)
    filter = Net::LDAP::Filter.eq("uid", uid) # XXX Why can't we search by DN ? I used uid instead but it's not supposed to be a primary key... :(
    results = Array.new()
    ldap_con.search(:base => BASE, :filter => filter) do |entry|
      attr_list = Hash.new()
      entry.each do |k, v|
        if v.class.to_s == "Array" and v.length == 1
          v = String.new(v.first)
        end
        attr_list[k] = v
      end
      results.push(attr_list)
    end
    # XXX ugly: other results (if any) are ignored. That why using DN as search criterion is the right thing to do (see above).
    if results.length > 0
      return results.first
    end
    return false
  end

end