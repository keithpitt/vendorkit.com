ENV["RAILS_ENV"] ||= 'test'
require 'rubygems'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'forgery'
require 'json'
require 'carrierwave/test/matchers'
require 'factory_girl_rails'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.include Devise::TestHelpers, :type => :controller
end


# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
