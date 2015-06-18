require "json"

module Keboola
  module GoodDataWriter

    class Parser
      def self.parse(string)
        begin
          JSON.parse(string)
        rescue JSON::ParserError, TypeError => e
          raise ParsingError.new(e.message)
        end
      end

      def parse(string)
        self.class.parse(string)
      end
    end

  end
end
