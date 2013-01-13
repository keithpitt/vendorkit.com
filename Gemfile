source 'http://rubygems.org'

ruby '1.9.3'

# Use latest rack to get rid of pesky errors
gem 'rack'

# Rails 3.1, oooer
gem 'rails'

# Postgres database
gem 'pg'

# jQuery for rails
gem 'jquery-rails'

# Authentication with devise
gem 'devise'

# File Uploads
gem 'carrierwave'

# And storage on S3
gem 'fog'

# Unzipping pants
gem 'rubyzip'

# For better ActiveRecord searching
gem "squeel"

# I need parts of vendor to do awesome stuff
gem 'vendor', :git => 'git://github.com/keithpitt/vendor.git'

# Capture errors
gem 'airbrake'

# Text formatting
gem 'redcarpet'

# Posting to twitter
gem 'twitter'

# And shortening URLS for twitter
gem 'is-gd-shrinker'

# For background stuffs
# Paticular versions so we can use auto-scale
gem 'resque', '1.10.0'
gem 'json', '1.4.6'

# For cheap heroku scaling stuff
gem 'heroku-resque-auto-scale'

# Gems used only for assets and not required
# in production environments by default.
group :assets do

  # Sass stylesheets
  gem 'sass-rails'

  # Coffeescript for nicer JavaScript
  gem 'coffee-rails'

  # Compressionn gem for CSS/JavaScript
  gem 'uglifier'

end

group :development do

  # Running multiple proccess easier
  gem 'foreman'

end

group :development, :test do

  # To use debugger
  # gem 'ruby-debug19', :require => 'ruby-debug'

  # Rails love for RSpec
  gem 'rspec-rails'

end

group :test do

  # Cucumber for testing
  gem 'cucumber-rails', :require => false

  # Better rspec formatter
  gem 'fuubar'

  # Headless testing
  gem 'capybara-webkit'

  # Testing Resque
  gem 'resque_spec'

  # Code coverage
  # gem 'rcov'

  # For easier tests
  gem 'shoulda-matchers'

  # Generating testing + dummy data
  gem 'factory_girl_rails', :require => false

  # For fake data
  gem 'forgery'

  # I like to have a clean ship
  gem 'database_cleaner'

  # Growl integration
  gem 'growl'

end

group :production do

  # Speed watch
  gem 'newrelic_rpm'

end
