# frozen_string_literal: true

module Logging
  module SemanticLogger
    module Formatters
      class OpenTelemetryJson < ::SemanticLogger::Formatters::Json
        def initialize(...)
          @sensitive_data_filter = ActiveSupport::ParameterFilter.new(Rails.configuration.filter_parameters)
          super(...)
        end

        def duration
          return unless log.duration

          hash[:duration] = (log.duration * 1000 * 1000).round(2)
        end

        def payload
          return if log.payload.to_h.empty?

          hash
            .deep_merge!(log.payload)
            .then { |payload| @sensitive_data_filter.filter(payload) }
        end

        def named_tags
          return if log.named_tags.to_h.empty?

          hash
            .deep_merge!(log.named_tags)
            .then { |payload| @sensitive_data_filter.filter(payload) }
        end

        def exception
          return unless log.exception

          root = hash
          log.each_exception do |exception, i|
            name = i.zero? ? :exception : :cause
            root[name] = {
              name: exception.class.name,
              message: exception.message,
              stack_trace: exception.backtrace
            }
            root = root[name]
          end
        end

        private

        module HTTPAttributes
          BASE = %i[headers format method params status status_message url].freeze
          RAILS = %i[action controller].freeze
          ALL = BASE + RAILS
        end
      end
    end
  end
end
