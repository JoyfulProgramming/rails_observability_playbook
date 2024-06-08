# frozen_string_literal: true

module Persistence
  class SpanRepo
    include Enumerable

    def initialize(spans:)
      @spans = spans.map { |span_or_spandata| Span.from_span_or_spandata(span_or_spandata) }
    end

    def each(&block)
      @spans.each(&block)
    end

    def in_code_namespace(namespace)
      select { |span| span.code_namespace == namespace }
    end

    def in_root_trace
      self.class.new(spans: group_by(&:trace_id).find { |_trace_id, spans| spans.count > 1 }.second)
    end

    def find_one!(attrs: {}, &block)
      block = to_block(attrs) if attrs.any? && !block_given?

      if one?(&block)
        find(&block)
      elsif empty?(&block)
        raise_none_found
      else
        raise_too_many_found(&block)
      end
    end

    def empty?(&block)
      count(&block).zero?
    end

    def raise_none_found
      raise ArgumentError, 'Nothing found'
    end

    def raise_too_many_found(&block)
      matched = select(&block)
      raise ArgumentError, "Too many found:\n#{matched.ai}"
    end

    def to_block(query)
      lambda do |object|
        object.attrs.deep_stringify_keys.slice(*query.deep_stringify_keys.keys) == query.deep_stringify_keys
      end
    end
  end
end
