# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
require 'webmock/rspec'
require 'capybara/rspec'
require 'capybara'
require 'capybara/dsl'
require 'webdrivers'

WebMock.disable_net_connect!(allow_localhost: true)

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

# Add additional requires below this line. Rails is not loaded until this point!
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# Rails.root.glob('spec/support/**/*.rb').sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  # Include CouchbaseMock module to mock Couchbase connections
  config.include CouchbaseMock
  config.include WhatsappMock
  config.include Capybara::DSL

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://rspec.info/features/6-0/rspec-rails
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # Capybara configuration for feature tests
  config.before(:each, type: :system) do
    driven_by(:playwright)
  end

  config.before(:each) do
    RSpec::Mocks.space.reset_all
  end

  config.before(:each) do
    stub_request(:get, %r{https://chromedriver\.storage\.googleapis\.com/.*})
      .to_return(status: 200, body: "", headers: {})
  end

  Webdrivers::Chromedriver.required_version = '114.0.5735.90'
end

# Capybara configuration
Capybara.configure do |config|
  config.default_driver = :selenium_chrome_headless
end
