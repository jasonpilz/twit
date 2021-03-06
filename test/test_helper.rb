ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'
require 'mocha/mini_test'
require 'simplecov'
require 'minitest/pride'
require 'webmock'
require 'vcr'

SimpleCov.start("rails")

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  VCR.configure do |config|
    config.cassette_library_dir = "test/cassettes"
    config.hook_into(:webmock)
  end

end

class ActionDispatch::IntegrationTest
  include Capybara::DSL

  def setup
    Capybara.app = Twit::Application
    stub_omniauth
  end

  def teardown
    reset_session!
  end

  def stub_omniauth
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
      provider: 'twitter',
      extra: {
        raw_info: {
          user_id: "4579816278",
          name: "Jason Michael Pilz",
          screen_name: "jaspil_dev",
        }
      },
      credentials: {
        token: ENV['TEST_TOKEN'],
        secret: ENV['TEST_SECRET']
      }
    })
  end

  def login_user
    visit "/"
    click_link("Twitter")
  end
end

DatabaseCleaner.strategy = :transaction

class Minitest::Spec
  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end
end
