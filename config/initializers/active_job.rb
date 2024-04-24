# frozen_string_literal: true

require 'opentelemetry/sdk'

OpenTelemetry::SDK.configure do |c|
  c.use_all

  if Rails.env.test?
    c.logger = Logger.new(IO::NULL)
    c.add_span_processor(
      OpenTelemetry::SDK::Trace::Export::SimpleSpanProcessor.new(
        OpenTelemetry::SDK::Trace::Export::InMemorySpanExporter.new
      )
    )
  elsif Rails.env.production?
    c.add_span_processor(
      OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
        OpenTelemetry::Exporter::OTLP::Exporter.new
      )
    )
  end
end

module Observable
  module Instrumentation
    # ActiveJob instrumentation
    class ActiveJobSubscriber
      def subscribe
        {
          'enqueue' => Handlers::EnqueueHandler.new,
          'perform' => Handlers::PerformHandler.new
        }.each { |event, handler| ActiveSupport::Notifications.subscribe("#{event}.active_job", handler) }
      end

      module Handlers
        # ActiveJob handlers
        class EnqueueHandler
          def initialize
            @mapper = ::OpenTelemetry::Instrumentation::ActiveJob::Mappers::Attribute.new
          end

          def call(event)
            attributes = @mapper.call(event.payload).merge(
              'message' => 'Job enqueued',
              'event.name' => 'app.job.enqueued'
            )
            Rails.logger.info(attributes)
          end
        end

        # ActiveJob handlers
        class PerformHandler
          def initialize
            @mapper = ::OpenTelemetry::Instrumentation::ActiveJob::Mappers::Attribute.new
          end

          def call(event)
            attributes = @mapper.call(event.payload).merge(
              'message' => 'Job performed',
              'event.name' => 'app.job.performed'
            )
            Rails.logger.info(attributes)
          end
        end
      end
    end
  end
end

Observable::Instrumentation::ActiveJobSubscriber.new.subscribe
