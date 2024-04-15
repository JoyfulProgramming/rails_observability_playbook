source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.1"

gem "bootsnap", require: false
gem "faraday", "~> 2.9"
gem "importmap-rails"
gem "jbuilder"
gem "pg", "~> 1.1"
gem "propshaft"
gem "puma", "~> 5.0"
gem "rails", "~> 7.0.4"
gem "rails_semantic_logger", "~> 4.14"
gem "redis", "~> 4.0"
gem "semantic_logger", "~> 4.15"
gem "sidekiq", "~> 7.2"
gem "stimulus-rails"
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "rspec", "~> 3.13"
  gem "rspec-rails", "~> 6.1"
  gem "selenium-webdriver"
  gem "vcr", "~> 6.2"
  gem "webdrivers"
  gem "webmock", "~> 3.23"
end
