# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.1'

gem 'bootsnap', require: false
gem 'dry-struct', '~> 1.6'
gem 'faraday', '~> 2.9'
gem 'importmap-rails'
gem 'jbuilder'
gem 'opentelemetry-exporter-otlp', '~> 0.26.3'
gem 'opentelemetry-instrumentation-all',
    github: 'joyfulprogramming/opentelemetry-ruby-contrib',
    branch: 'main',
    glob: 'instrumentation/*/*.gemspec'
gem 'opentelemetry-sdk', '~> 1.4'
gem 'pg', '~> 1.1'
gem 'propshaft'
gem 'puma', '~> 5.0'
gem 'rails', '~> 7.0.4'
gem 'rails_semantic_logger', '~> 4.14'
gem 'redis', '~> 4.0'
gem 'semantic_logger', '~> 4.15'
gem 'sentry-rails', '~> 5.17'
gem 'sentry-ruby', '~> 5.17'
gem 'sidekiq', '~> 7.2'
gem 'stimulus-rails'
gem 'turbo-rails'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  gem 'debug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem 'spring', '~> 4.2'
  gem 'spring-commands-rspec', '~> 1.0'
  gem 'standardrb'
  gem 'web-console'
end

group :test do
  gem 'awesome_print', '~> 1.9'
  gem 'capybara'
  gem 'rspec', '~> 3.13'
  gem 'rspec-rails', '~> 6.1'
  gem 'selenium-webdriver'
  gem 'super_diff', '~> 0.11.0'
  gem 'vcr', '~> 6.2'
  gem 'webdrivers'
  gem 'webmock', '~> 3.23'
end
