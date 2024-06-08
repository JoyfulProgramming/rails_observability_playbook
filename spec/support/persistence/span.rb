# frozen_string_literal: true

module Persistence
  class Span < Dry::Struct
    attribute :id, Dry.Types::String
    attribute :name, Dry.Types::String
    attribute :kind, Dry.Types::Symbol
    attribute :trace_id, Dry.Types::String
    attribute :attrs, Dry.Types::Hash

    def hex_trace_id
      trace_id
    end

    def hex_span_id
      id
    end

    def code_namespace
      attrs["code.namespace"] || attrs["messaging.sidekiq.job_class"] || ""
    end

    def producer?
      kind == :producer
    end

    def consumer?
      kind == :consumer
    end

    def self.from_spandata(span_or_spandata)
      new(
        id: span_or_spandata.hex_span_id,
        trace_id: span_or_spandata.hex_trace_id,
        name: span_or_spandata.name,
        kind: span_or_spandata.kind,
        attrs: span_or_spandata.attributes
      )
    end

    def self.from_span_or_spandata(span_or_spandata)
      if span_or_spandata.is_a?(Span)
        span_or_spandata
      else
        from_spandata(span_or_spandata)
      end
    end
  end
end
