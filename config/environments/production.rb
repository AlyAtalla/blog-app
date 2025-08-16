# ensure these are present (Rails adds them by default)
config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
config.assets.compile = false
