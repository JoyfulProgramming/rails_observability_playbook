# frozen_string_literal: true

module Persistence
  class TraceRepo
    include Enumerable

    def initialize(spans:)
      @traces = spans.group_by(&:hex_trace_id).map { |id, spandatas| Trace.from_id_and_spandatas(id:, spandatas:) }
    end

    def each(&block)
      @traces.each(&block)
    end

    def root!
      find_one!(&:root?)
    end

    def empty?(&block)
      count(&block).zero?
    end

    def find_one!(&block)
      if one?(&block)
        find(&block)
      elsif empty?(&block)
        raise_none_found
      else
        raise_too_many_found
      end
    end

    def raise_none_found
      raise ArgumentError, 'Nothing found'
    end

    def raise_too_many_found
      raise ArgumentError, 'Too many found'
    end
  end
end
