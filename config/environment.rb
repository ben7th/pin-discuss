# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

MINDPIN_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/mindpin_config.yml")[RAILS_ENV]

ATTACHED_FILE_PATH_ROOT = MINDPIN_CONFIG['ATTACHED_FILE_PATH_ROOT']
ATTACHED_FILE_URL_ROOT = MINDPIN_CONFIG['ATTACHED_FILE_URL_ROOT']
APP_PREFIX = MINDPIN_CONFIG['APP_PREFIX']
THIS_SITE = MINDPIN_CONFIG['THIS_SITE']
RSS_THUMB_SITE = MINDPIN_CONFIG['RSS_THUMB_SITE']
IMAGE_CACHE_SITE = MINDPIN_CONFIG['IMAGE_CACHE_SITE']
REPOSITORY_SERVICE_SITE = MINDPIN_CONFIG["REPOSITORY_SERVICE_SITE"]
GIT_REPO_PATH = MINDPIN_CONFIG["GIT_REPO_PATH"]

CELLS = [:panel,:paper]

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  config.load_paths += %W( #{RAILS_ROOT}/app/middlewares )
  config.load_paths += %W( #{RAILS_ROOT}/lib/auth )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem 'mislav-will_paginate', :version => '~> 2.3.8', :lib => 'will_paginate', :source => 'http://gems.github.com'
  config.gem "rubyzip", :version => '0.9.1', :lib => "zip/zip"
  config.gem "nokogiri"
  config.gem "sanitize"
  config.gem "haml"

  config.gem "pie-auth"
  config.gem "pie-ui"
  config.gem "pie-repo"
  config.gem "uuidtools"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  #   config.active_record.observers = :cacher, :garbage_collector, :forum_observer
  #  config.active_record.observers = :user_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'Beijing'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  #  config.i18n.default_locale = :cn
  config.i18n.default_locale = :cn

  config.load_paths += %W( #{RAILS_ROOT}/lib/mail_receive )
end

require "ap"

ActionMailer::Base.smtp_settings = {
  :address => "mail.mindpin.com",
  :domain => "mindpin.com",
  :authentication => :plain,
  :user_name => "mindpin",
  :password => "m1ndp1ngood!!!"
}