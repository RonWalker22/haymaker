source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby '2.6.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '6.0.0.rc1'
# Use postgresql as the database for Active Record

gem 'rails-html-sanitizer', '~> 1.0.4'

gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby


gem 'sprockets', '~> 3.7.2'

gem 'sprockets-rails', :require => 'sprockets/railtie'

gem 'jquery-rails'

gem 'popper_js', '~> 1.14.3'

gem "font-awesome-rails"


# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '>= 4.1.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.11'

gem 'faker'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
  gem 'rails-controller-testing'
  gem 'minitest', '>= 5.11.3'
  gem 'minitest-reporters'
  gem 'rb-readline'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'pry'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem "bulma-rails", "~> 0.6.2"

gem 'httparty'

gem 'faye-websocket'

gem 'devise'

gem 'sidekiq', ">= 5.2.5"

gem 'sidekiq-scheduler'

gem 'kaminari'

gem 'local_time'

gem 'eventmachine'

gem "loofah", ">= 2.2.3"

gem "rack", ">= 2.0.6"

gem "rubyzip", ">= 1.2.2"

gem "nokogiri", ">= 1.8.5"

gem 'bootsnap', require: false

gem 'websocket-eventmachine-client'

gem "actionview", ">= 6.0.0.rc1"

gem "railties", ">= 6.0.0.rc1"

gem "bootstrap", ">= 4.3.1"