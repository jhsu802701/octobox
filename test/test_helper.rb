# frozen_string_literal: true

require "simplecov"
SimpleCov.start 'rails' do
  track_files "{lib}/*.rb" # Not automatically covered under the rails profile
end

# From https://github.com/colszowka/simplecov/issues/401
Dir[Rails.root.join('lib/*.rb')].each {|file| load file }

# BEGIN: Codecov
# Run Codecov ONLY in continuous integration.
# Running Codecov suppresses the display of the test coverage percentage
# in the terminal screen output.
if ENV.include? 'CODECOV_TOKEN'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
# END: Codecov

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'webmock/minitest'
require 'mocha/minitest'

require 'sidekiq_unique_jobs/testing'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

Dir[Rails.root.join('test/support/**/*.rb')].each { |f| require f }

FactoryBot.find_definitions

puts "We are using #{ActiveRecord::Base.connection.adapter_name}"

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include FactoryBot::Syntax::Methods
  include SidekiqMinitestSupport
  include StubHelper
end

class ActionDispatch::IntegrationTest
  include SignInHelper
  include StubHelper
end

module NotificationTestHelper
  def build_expected_attributes(expected_notifications, keys: nil)
    keys ||= DownloadService::API_ATTRIBUTE_MAP.keys
    expected_notifications.map{|n|
      notification = Notification.new
      notification.attributes = Notification.attributes_from_api_response(n)
      attrs = notification.attributes
      notification.destroy
      attrs.slice(*(keys.map(&:to_s)))
    }
  end

  def notifications_from_fixture(fixture_file)
    Oj.load(file_fixture(fixture_file).read, object_class: OpenStruct).tap do |notifications|
      notifications.map { |n| n.last_read_at = Time.parse(n.last_read_at).to_s if n.last_read_at }
    end
  end
end
