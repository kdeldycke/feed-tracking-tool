# Be sure to restart your web server when you modify this file.

# ************************ FTT GLOBAL CONFIG ************************
FTT_VERSION    = "0.10.0-trunk"
FTT_PUBLIC_URL = "http://localhost:3000"  # No need of trailing slash
                                          # TODO: Is this can be guessed automaticaly ?

# Articles config
FEED_UPDATE_DELAY        = 60 * 60           # Update a feed every hour (= 60 minutes * 60 seconds)
ARTICLE_EXPIRATION_DELAY = 31 * 24 * 60 * 60 # Remove all articles older than a month (= 31 days * 24 hours * 60 minutes * 60 seconds)

# UI date format
DATE_FORMAT = "%d %b %Y, %H:%M"

# HTTP proxy
HTTP_PROXY_HOST = "12.34.56.78"
HTTP_PROXY_PORT = 8080

# Mail config
MSMTP_BIN = "/usr/bin/msmtp"

# *******************************************************************

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

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile


# Keep table name simple: bypass pluralization
ActiveRecord::Base.pluralize_table_names = false

# We use the external MSMTP tool to send mail via SMTPs protocol: ActionMailer doesn't support TLS (yet ?)
# You can test MSMTP from a shell terminal with following command: `msmtp -d test@mydomain.com`
# MSMTP documentation: http://msmtp.sourceforge.net/doc/msmtp.html#Configuration-files
# TODO: Use pure ruby based solution like http://blog.pomozov.info/posts/how-to-send-actionmailer-mails-to-gmailcom.html ?
ActionMailer::Base.delivery_method = :msmtp

# Normalize and builed path
RAILS_PATH = Pathname.new(RAILS_ROOT).realpath.to_s
MSMTP_CONF = File.join(RAILS_PATH, "config", "msmtp.conf")
MSMTP_LOG  = File.join(RAILS_PATH, "log", "msmtp.log")
MSMTP_BIN  = Pathname.new(MSMTP_BIN).realpath.to_s  # TODO: generate path dynamiccaly ?
# TODO: Check here that msmtp is installed and available on the system

# Register MSMTP sending method in Action Mailer
module ActionMailer
  class Base
    def perform_delivery_msmtp(mail)
      # Adjust MSMTP configuration and log file
      File.chmod(0600, MSMTP_CONF)
      FileUtils.chown(ENV['USER'], nil, MSMTP_CONF)
      if not File.exist? MSMTP_LOG
        f = File.new(MSMTP_LOG, "w+")
        f.close
      end
      # Build-up MSMTP command-line
      mail_cmd = %(#{MSMTP_BIN} -t -C "#{MSMTP_CONF}" --logfile="#{MSMTP_LOG}" -a provider --)
      logger.info("Try to send mail with MSMTP: `#{mail_cmd}`")
      # Send the mail
      IO.popen(mail_cmd, "w") do |sm|
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
FeedTools.configurations[:proxy_address] = HTTP_PROXY_HOST
FeedTools.configurations[:proxy_port] = HTTP_PROXY_PORT


# Calculate proxy URL
HTTP_PROXY_URL = "http://#{HTTP_PROXY_HOST}:#{HTTP_PROXY_PORT}"


# Monkey patch feedalizer to support page grabbing through a proxy
require 'feedalizer'
class Feedalizer
  # Backup original grab_page method
  alias_method :grab_page_orig, :grab_page
  # Define new grab_page() method with proxy support
  def grab_page(url)
    open(url, :proxy => HTTP_PROXY_URL) { |io| Hpricot(io) }
  end
end


# TODO: search for a rails generic method to convert Time object to mysql datetime
MYSQL_DATE_FORMAT = "%Y-%m-%d %H:%M:%S"
