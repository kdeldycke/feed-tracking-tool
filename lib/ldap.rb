require 'net/ldap'
module LDAP
  def self.authenticate(user,password)
    if user == "" || password == ""
      return false
    end
    ldap_con = Net::LDAP.new({
      :host => 'ldap.company.com',
      #:port => 389,
      :auth => {
        :method => :simple,
        :username => user,
        :password => password } } )
    return true if ldap_con.bind
    return false
  end
end
