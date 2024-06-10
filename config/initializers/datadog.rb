# frozen_string_literal: true

Rails.application.config.after_initialize do
  if ENV["DISABLE_DATADOG_AGENT"].blank? && !Rails.env.local?
    Rails.application.configure do
      config.semantic_logger.add_appender(
        appender: :tcp,
        server: "127.0.0.1:10518",
        formatter: :json
      )
    end
  end
end
