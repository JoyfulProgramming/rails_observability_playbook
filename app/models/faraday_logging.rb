class FaradayLogging < ::Faraday::Middleware
  def on_complete(env)
    Rails.logger.info(
      message: "#{env.method.to_s.upcase} #{env.url}",
      event: {
        name: "http.request.made",
      },
      http: {
        request: build_request(env),
        response: build_response(env),
      }
    )
  end

  def build_request(env)
    filter.filter(
      method: env.method.to_s.upcase,
      headers: env.request_headers,
      body: env.request_body,
      url: env.url,
    )
  end

  def build_response(env)
    filter.filter(
      status_code: env.status,
      headers: env.response_headers,
      body: env.response_body,
    )
  end

  def filter
    @_filter ||= ActiveSupport::ParameterFilter.new(Rails.configuration.filter_parameters)
  end
end
