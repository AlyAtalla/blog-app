if ENV['RAILS_SKIP_DATABASE'] == 'true'
  # completely disable database connection
  config.before_initialize do
    module ActiveRecord
      class Base
        def self.establish_connection(*)
          # no-op
        end
      end
    end
  end
end
