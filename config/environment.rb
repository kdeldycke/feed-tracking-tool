# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '1.2.3' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here

  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  # See Rails::Configuration for more options
end

# Add new inflection rules using the following format
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile


# Include your application configuration below
ActiveRecord::Base.pluralize_table_names = false

# Msmtp is required to send mail via SMTPs protocol
ActionMailer::Base.delivery_method = :msmtp

module ActionMailer
  class Base
    def perform_delivery_msmtp(mail)
      # TODO: generate absolute path below dynamiccaly
      # MSMTP config file is located at $HOME/.msmtprc
      # MSMTP config file content:
      #   account provider
      #   host smtp.uperto.com
      #   auth on
      #   port 25
      #   user *******
      #   password *********
      #   maildomain uperto.com
      #   tls on
      #   tls_starttls on
      #   tls_certcheck off
      #   auto_from on
      #   logfile ~/msmtp.log
      #
      #   account default : provider
      # Shell test command: `msmtp -d test@mydomain.com`
      # MSMTP documentation: http://msmtp.sourceforge.net/doc/msmtp.html#Configuration-files
      IO.popen("/usr/bin/msmtp -t -C /root/.msmtprc -a provider --", "w") do |sm|
        sm.puts(mail.encoded.gsub(/\r/, ''))
        sm.flush
      end
      if $? != 0
        # why >> 8? because this is posix and exit code is in bits 8-16
        logger.error("failed to send mail errno #{$? >> 8}")
      end
    end
  end
end


# Force unicode support (default is UFT8 but we force it anyway to feel good... ;) )
$KCODE = 'u'
require_dependency 'jcode'


# Feed tool import and global config
require 'feed_tools'
require 'monkey_patch_feed_tool'  # Monkey patch feed tool to force UTF-8 parsing of some html entities
FeedTools.configurations[:proxy_address] = "12.34.56.78"
FeedTools.configurations[:proxy_port] = 8080
