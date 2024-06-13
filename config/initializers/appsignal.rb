# frozen_string_literal: true

class AppSignalJson < ::SemanticLogger::Formatters::Json
  def call(log, logger)
    # {}.to_json + "\n"
    # # super(log, logger).to_json + "\n"
    %({ "timestamp": "2022-06-02T04:17:25.783Z", "group": "application", "severity": "warn", "message": "This is a test message", "hostname": "frontend1", "attributes": { "org": "appsignal", "step": 1, "seen_terms": true, "entries": 10.01 } })
  end
end

module SemanticLogger
  module Appender
    class AppSignalHttp < SemanticLogger::Appender::Http
      # Create AppSignal appender over persistent HTTP(S)
      #
      # Parameters:
      #   api_key: [String]
      #     Key
      #     Mandatory.
      #
      #   url: [String]
      #     Valid URL to post to.
      #       Example: http://example.com
      #     To enable SSL include https in the URL.
      #       Example: https://example.com
      #       verify_mode will default: OpenSSL::SSL::VERIFY_PEER
      #
      #   application: [String]
      #     Name of this application to appear in log messages.
      #     Default: SemanticLogger.application
      #
      #   host: [String]
      #     Name of this host to appear in log messages.
      #     Default: SemanticLogger.host
      #
      #   compress: [true|false]
      #     Splunk supports HTTP Compression, enable by default.
      #     Default: true
      #
      #   ssl: [Hash]
      #     Specific SSL options: For more details see NET::HTTP.start
      #       ca_file, ca_path, cert, cert_store, ciphers, key, open_timeout, read_timeout, ssl_timeout,
      #       ssl_version, use_ssl, verify_callback, verify_depth and verify_mode.
      #
      #   level: [:trace | :debug | :info | :warn | :error | :fatal]
      #     Override the log level for this appender.
      #     Default: SemanticLogger.default_level
      #
      #   formatter: [Object|Proc]
      #     An instance of a class that implements #call, or a Proc to be used to format
      #     the output from this appender
      #     Default: Use the built-in formatter (See: #call)
      #
      #   filter: [Regexp|Proc]
      #     RegExp: Only include log messages where the class name matches the supplied.
      #     regular expression. All other messages will be ignored.
      #     Proc: Only include log messages where the supplied Proc returns true
      #           The Proc must return true or false.
      def initialize(api_key: nil,
        **args,
        &block)

        @api_key = api_key
        super(**args, &block)
      end

      def log(log)
        message = formatter.call(log, self)
        logger.trace(message)
        post(message, "#{@path}?api_key=#{@api_key}")
      end
    end
  end
end

Rails.application.config.after_initialize do
  Rails.application.configure do
    config.semantic_logger.add_appender(
      appender: SemanticLogger::Appender::AppSignalHttp.new(
        api_key: ENV.fetch("APPSIGNAL_API_KEY"),
        url: "https://appsignal-endpoint.net/logs",
        formatter: AppSignalJson.new
      )
    )
  end
end
