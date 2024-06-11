require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsObservabilityPlaybook
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.generators do |g|
      g.test_framework :rspec,
        fixtures: false,
        view_specs: true,
        helper_specs: false,
        routing_specs: false,
        controller_specs: true,
        request_specs: true
      g.fixture_replacement :factory_bot, dir: "spec/factories"
      g.orm :active_record, primary_key_type: :uuid
    end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.autoload_paths << Rails.root.join("lib")

    config.rails_semantic_logger.semantic = false

    config.log_tags = {
      event: {
        name: "http.request.handled"
      },
      http: lambda do |request|
        {
          request: {
            id: request.request_id,
            header: request
              .headers
              .to_h
              .select { |key, _value| key.start_with?("HTTP_") }
              .transform_keys { |key| key.sub(/^HTTP_/, "").downcase }
              .then { |headers| ActiveSupport::ParameterFilter.new(Rails.configuration.filter_parameters).filter(headers) },
            method: request.method,
            size: request.content_length
          }
        }
      end,
      client: lambda do |request|
        {
          address: request.remote_ip
        }
      end,
      url: lambda do |request|
        {
          full: request.original_url
        }
      end,
      user_agent: lambda do |request|
        {
          original: request.user_agent
        }
      end
    }
  end
end
