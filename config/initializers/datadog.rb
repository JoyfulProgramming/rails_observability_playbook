# frozen_string_literal: true

Rails.application.config.after_initialize do
  if ENV["DISABLE_DATADOG_AGENT"].blank? && !Rails.env.local?
    begin
      Rails.application.configure do
        config.semantic_logger.add_appender(
          appender: :tcp,
          server: "127.0.0.1:10518",
          formatter: Logging::SemanticLogger::Formatters::OpenTelemetryJson.new
        )
      end
    rescue Net::TCPClient::ConnectionFailure
      Rails.logger.warn "Failed to connect to Datadog Agent"
    end
  end
end
