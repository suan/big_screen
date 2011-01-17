# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_big_screen_session',
  :secret      => '4d63ccbdddc149e703902e20a93cfc679bf088e65e0202f28af7114b96038ef8b828c16b245adb55d5ee7f62051dcce5b65740efbc724f7d34e2f9355ea9126b'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
