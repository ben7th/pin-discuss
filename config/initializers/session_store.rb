# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.

case RAILS_ENV
when 'production'
  ActionController::Base.session = {
    :key=>'_mindpin_ei_session',
    :secret=>'883abe7844502ee307e376fa4d0509253d7f9e55fc8be69a934735cd470cc8671af39e27482885960f3364fa8af420b5519571193e22987c3e9e4f9da29f15fb'
  }
else
  ActionController::Base.session = {
    :key=>'_mindpin_ei_session_dev',
    :secret=>'883abe7844502ee307e376fa4d0509253d7f9e55fc8be69a934735cd470cc8671af39e27482885960f3364fa8af420b5519571193e22987c3e9e4f9da29f15fb'
  }
end



ActionController::Dispatcher.middleware.insert_before(ActionController::Base.session_store,
  FlashSessionCookieMiddleware, ActionController::Base.session_options[:key])

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
