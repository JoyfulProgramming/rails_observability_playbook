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

          payload_with_nested_attributes = log.
                                           payload.
                                           then(&nest_http_attributes).
                                           then(&nest_db_statement)
          hash.
            deep_merge!(payload_with_nested_attributes).
            then { |payload| @sensitive_data_filter.filter(payload) }
        end

        def named_tags
          return if log.named_tags.to_h.empty?

          hash.
            deep_merge!(log.named_tags).
            then { |payload| @sensitive_data_filter.filter(payload) }
        end

        def exception
          return unless log.exception

          root = hash
          log.each_exception do |exception, i|
            name       = i.zero? ? :exception : :cause
            root[name] = {
              name: exception.class.name,
              message: exception.message,
              stack_trace: exception.backtrace,
            }.merge(context: decorated_exception(exception).context)
            root = root[name]
          end
        end

        private

        module HTTPAttributes
          BASE = [:headers, :format, :method, :params, :status, :status_message, :url].freeze
          RAILS = [:action, :controller].freeze
          ALL = BASE + RAILS
        end

        def decorated_exception(exception)
          exception_decorator_class(exception).new(exception)
        end

        def exception_decorator_class(exception)
          "Logging::ExceptionDecorators::#{exception.class.name}Decorator".safe_constantize ||
            Logging::ExceptionDecorators::BaseDecorator
        end

        def nest_http_attributes
          lambda do |payload|
            payload
              .deep_merge(
                http: {
                  server: {
                    request: {
                      duration: payload[:duration],
                    }
                  },
                  request: { action: payload[:action], resource: payload[:controller] }.then(&add_resource),
                  response: { status_code: payload[:status] }
                }
              )
          end
        end

        def add_resource
          lambda do |rails_attrs|
            return rails_attrs if rails_attrs[:controller].blank? || rails_attrs[:action].blank?

            resource = (rails_attrs[:controller] || "").underscore.gsub(/_controller$/, "")
            rails_attrs.merge(
              resource: resource,
              resource_and_action: "#{resource}##{rails_attrs[:action]}",
            )
          end
        end

        def nest_db_statement
          lambda do |payload|
            return payload.except(:sql) if payload.exclude?(:sql) || payload[:sql].blank?

            payload.
              except(:sql).
              deep_merge(
                db: {
                  statement: payload.fetch(:sql).to_s,
                  operation: payload.fetch(:sql).to_s.split.first,
                },
              )
          end
        end

        def rename_status_to_status_code
          ->(key) { key == :status ? :status_code : key }
        end
      end
    end
  end
end