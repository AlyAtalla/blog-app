# This file is used by RSpec to load your Rails application.

# Add additional requires below this line. Rails is not loaded until this point!

require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)

abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

# Configure RSpec to run specs in random order to ensure isolation of tests.
RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include FactoryBot::Syntax::Methods

  # Add other configuration as needed.
end
