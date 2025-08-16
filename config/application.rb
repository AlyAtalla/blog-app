require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BlogApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Add all subdirectories of `lib` to the autoload paths, except for `assets` and `tasks`.
    Dir[Rails.root.join('lib', '**/')].each do |directory|
      config.autoload_paths << directory unless %w(assets tasks).include?(File.basename(directory))
    end

    # ----------------------------
    # Skip database initialization when precompiling assets
    # ----------------------------
    if ENV['RAILS_SKIP_DATABASE'] == 'true'
      config.before_initialize do
        # no-op connection prevents DB connection during assets:precompile
        ActiveRecord::Base.establish_connection = -> {}
      end

      config.active_record.migration_error = false
      config.active_record.dump_schema_after_migration = false
      config.active_record.database_selector = nil
      config.active_record.database_resolver = nil
      config.active_record.database_resolver_context = nil
      config.active_record.maintain_test_schema = false
      config.active_record.schema_format = :ruby
      config.active_record.sqlite3.represent_boolean_as_integer = true if defined?(ActiveRecord::ConnectionAdapters::SQLite3Adapter)
    end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
