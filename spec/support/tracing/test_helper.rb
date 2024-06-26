# frozen_string_literal: true

module Tracing
  module TestHelper
    def traces
      Persistence::TraceRepo.new(spans: finished_spans)
    end

    def spans
      Persistence::SpanRepo.new(spans: finished_spans)
    end

    def finished_spans
      open_telemetry_exporter.finished_spans
    end

    def open_telemetry_exporter
      Rails.configuration.open_telemetry_exporter
    end
  end
end
