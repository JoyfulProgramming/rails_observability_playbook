# frozen_string_literal: true

require "opentelemetry/sdk"

# rubocop:disable Metrics/BlockLength
OpenTelemetry::SDK.configure do |c|
  c.use "OpenTelemetry::Instrumentation::Rails"
  c.use "OpenTelemetry::Instrumentation::Sidekiq", {
    span_naming: :job_class,
    propagation_style: :child,
    trace_launcher_heartbeat: false,
    trace_poller_enqueue: false,
    trace_poller_wait: false,
    trace_processor_process_one: false,
    peer_service: nil
  }
  c.use "OpenTelemetry::Instrumentation::ActiveSupport"
  c.use "OpenTelemetry::Instrumentation::Rack", {
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
  c.use "OpenTelemetry::Instrumentation::ActionPack"
  c.use "OpenTelemetry::Instrumentation::ActiveRecord"
  c.use "OpenTelemetry::Instrumentation::ActionView", {
    disallowed_notification_payload_keys: [], notification_payload_transform: nil
  }
  c.use "OpenTelemetry::Instrumentation::ConcurrentRuby"
  c.use "OpenTelemetry::Instrumentation::Faraday", {span_kind: :client, peer_service: nil}
  c.use "OpenTelemetry::Instrumentation::PG",
    {peer_service: nil, db_statement: :obfuscate, obfuscation_limit: 2000}
  c.use "OpenTelemetry::Instrumentation::Rake"

  # c.add_span_processor(Rails.configuration.open_telemetry_span_processor)

  c.logger = Logger.new(IO::NULL) if Rails.env.test?
end
# rubocop:enable Metrics/BlockLength
