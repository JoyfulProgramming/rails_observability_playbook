# frozen_string_literal: true

require 'opentelemetry/sdk'

# rubocop:disable Metrics/BlockLength
OpenTelemetry::SDK.configure do |c|
  c.use 'OpenTelemetry::Instrumentation::Rails'
  c.use 'OpenTelemetry::Instrumentation::ActiveJob', {
    span_naming: :job_class,      # Options are :job_class or :queue
    force_flush: true,            # Options are true or false
    propagation_style: :child     # Options are :link, :child, or :none
  }
  c.use 'OpenTelemetry::Instrumentation::ActiveSupport'
  c.use 'OpenTelemetry::Instrumentation::Rack', {
    allowed_request_headers: [],
    allowed_response_headers: [],
    application: nil,
    record_frontend_span: false,
    untraced_endpoints: [],
    url_quantization: nil,
    untraced_requests: nil,
    response_propagators: [],
    use_rack_events: true,
    allowed_rack_request_headers: {},
    allowed_rack_response_headers: {}
  }

  c.use 'OpenTelemetry::Instrumentation::ActionPack'
  c.use 'OpenTelemetry::Instrumentation::ActiveRecord'
  c.use 'OpenTelemetry::Instrumentation::ActionView', {
    disallowed_notification_payload_keys: [], notification_payload_transform: nil
  }
  c.use 'OpenTelemetry::Instrumentation::ConcurrentRuby'
  c.use 'OpenTelemetry::Instrumentation::Faraday', { span_kind: :client, peer_service: nil }
  c.use 'OpenTelemetry::Instrumentation::Net::HTTP', { untraced_hosts: [] }
  c.use 'OpenTelemetry::Instrumentation::PG',
        { peer_service: nil, db_statement: :obfuscate, obfuscation_limit: 2000 }
  c.use 'Instrumentation: OpenTelemetry::Instrumentation::Rails'
  c.use 'OpenTelemetry::Instrumentation::Rake'

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
# rubocop:enable Metrics/BlockLength

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
