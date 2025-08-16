require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BlogApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Add all subdirectories of `lib` to autoload paths, except 'assets' and 'tasks'
    Dir[Rails.root.join('lib', '**/')].each do |directory|
      config.autoload_paths << directory unless %w[assets tasks].include?(File.basename(directory))
    end

    # ----------------------------
    # Skip database initialization when precompiling assets
    # Useful for Docker / Railway builds
    # ----------------------------
    if ENV['RAILS_SKIP_DATABASE'] == 'true'
      config.before_initialize do
        # No-op for database connection
        ActiveRecord::Base.establish_connection = -> { }
      end

      config.active_record.migration_error = false
      config.active_record.dump_schema_after_migration = false
      config.active_record.maintain_test_schema = false
      config.active_record.schema_format = :ruby
      if defined?(ActiveRecord::ConnectionAdapters::SQLite3Adapter)
        config.active_record.sqlite3.represent_boolean_as_integer = true
      end
    end

    # Use Rails credentials (requires master key)
    config.require_master_key = true

    # Serve static files and log to stdout for Railway
    config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
    config.logger = Logger.new(STDOUT) if ENV['RAILS_LOG_TO_STDOUT'].present?

    # Optional: set timezone (adjust as needed)
    # config.time_zone = "Cairo"
  end
end
