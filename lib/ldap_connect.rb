# Inspired by http://www.rich-waters.com/blog/2007/02/using-domino-logins-ldap-for-a-ruby-on-rails-app.html

require 'net/ldap'

module LDAP

  def self.authenticate(user, password)
    if user == "" || password == ""
      return false
    end
    ldap_con = Net::LDAP.new({:host => '12.34.56.78',
                              :port => 389,
                              :base => "dc=uperto",
                              :auth => {:method => :simple,
                                        :username => "uid=#{user},ou=users,dc=uperto",
                                        :password => password
                            }})

#     logger.info "Result: #{truc.get_operation_result.code}"
#     logger.info "Message: #{truc.get_operation_result.message}"

    return true if ldap_con.bind
    return false
  end

end