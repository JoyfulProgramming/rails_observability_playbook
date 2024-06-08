# frozen_string_literal: true

if Rails.env.development?
  Rails.application.config.after_initialize do
    Rails.application.configure do
      config.semantic_logger.add_appender(
        file_name: "log/development.log.json",
        formatter: Logging::SemanticLogger::Formatters::OpenTelemetryJson.new
      )
    end
  end
end
