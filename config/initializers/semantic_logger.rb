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

Rails.application.config.after_initialize do
  if Rails.configuration.rails_semantic_logger.semantic
    # Active Job
    if defined?(::ActiveJob)
      RailsSemanticLogger.swap_subscriber(
        RailsSemanticLogger::ActiveJob::LogSubscriber,
        Logging::RailsSemanticLogger::OpenTelemetryLogSubscriber,
        :active_job
      )
    end

    # Active Record
    if defined?(::ActiveRecord)
      require "active_record/log_subscriber"

      RailsSemanticLogger.swap_subscriber(
        ::ActiveRecord::LogSubscriber,
        RailsSemanticLogger::ActiveRecord::LogSubscriber,
        :active_record
      )
    end

    # Action Controller
    if defined?(::ActionController)
      require "action_controller/log_subscriber"

      RailsSemanticLogger.swap_subscriber(
        ::ActionController::LogSubscriber,
        RailsSemanticLogger::ActionController::LogSubscriber,
        :action_controller
      )
    end

    # Action Mailer
    if defined?(::ActionMailer)
      require "action_mailer/log_subscriber"

      RailsSemanticLogger.swap_subscriber(
        ::ActionMailer::LogSubscriber,
        RailsSemanticLogger::ActionMailer::LogSubscriber,
        :action_mailer
      )
    end
  end
end
