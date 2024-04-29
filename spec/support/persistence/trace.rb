# frozen_string_literal: true

module Persistence
  class Trace < Dry::Struct
    attribute :id, Dry.Types::String
    attribute :spans, Dry.Types::Array.of(Span)

    def self.from_id_and_spandatas(id:, spandatas:)
      new(
        id:,
        spans: spandatas.map { |spandata| Span.from_spandata(spandata) }
      )
    end

    def root?
      spans.count > 1
    end
  end
end
