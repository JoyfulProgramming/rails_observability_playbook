module Logging
  module TestHelper
    private

    def capture_logs(buffer: StringIO.new, formatter: Logging::SemanticLogger::Formatters::OpenTelemetryJson.new)
      ::SemanticLogger.flush
      begin
        appender = ::SemanticLogger.add_appender(io: buffer, formatter: formatter)
        yield
      ensure
        ::SemanticLogger.flush
        ::SemanticLogger.remove_appender(appender)
      end

      parsed(buffer)
    end

    def parsed(output)
      output.string.split("\n").map do |line|
        JSON.parse(line, symbolize_names: true)
      end
    end
  end
end
