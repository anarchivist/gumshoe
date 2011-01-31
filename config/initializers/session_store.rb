# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_gumshoe_session',
  :secret      => '7bb49cd8a9ea124e9ffa32f2d3b169f1943abdec3d91bb932b9f982bbf64dd2406755a3d43584195c9f13c01572d9c6adfb6eb358eb1b5904952ca66890480b8'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
