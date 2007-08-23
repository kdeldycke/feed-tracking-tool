class Profile < ActiveRecord::Base
  validates_presence_of :user_id
  validates_uniqueness_of :user_id
  # TODO: check against LDAP capabilities and character tolerance
  validates_format_of :user_id,
                      :with    => %r{^[a-zA-Z0-9]*}i,
                      :message => "must be a-Z and/or 0-9, no spaces or any other characters"
  # TODO: make the validation regexp match the RFC 822: http://www.freesoft.org/CIE/RFC/822/index.htm
  #     alt: http://tfletcher.com/lib/rfc822.rb
  # Suggested by http://nshb.net/rails-validates_format_of-email-email_address-regular_expression-php_option_too
  validates_format_of :email,
                      :with    =>  /^\S+\@(\[?)[a-zA-Z0-9\-\.]+\.([a-zA-Z]{2,4}|[0-9]{1,4})(\]?)$/ix,
                      :message => "was an invalid format"
end