# frozen_string_literal: true

# Path: app/models/faraday_logging.rb
class FaradayLogging < ::Faraday::Middleware
  def on_complete(env)
    Rails.logger.info(
      message: "#{env.method.to_s.upcase} #{env.url}",
      event: {
        name: "http.request.made"
      },
      http: {
        request: {
          method: env.method.to_s.upcase,
          headers: env.request_headers,
          body: env.request_body,
          url: env.url
        },
        response: {
          status_code: env.response.status,
          headers: env.response_headers,
          body: env.response_body
        }
      }
    )
  end

  def filter
    @filter ||= ActiveSupport::ParameterFilter.new(Rails.configuration.filter_parameters)
  end
end
