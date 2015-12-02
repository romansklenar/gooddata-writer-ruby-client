module Keboola
  module GoodDataWriter

    class Error < RuntimeError; end
    class ParsingError < Error; end

    class JobError < Error
      attr_reader :job

      def initialize(job)
        @job = job
        super job.result.fetch("message")
      end
    end

    class ResponseError < Error
      attr_reader :response

      def initialize(ex, response = nil)
        @wrapped_exception, @response = nil, response

        if ex.respond_to?(:backtrace)
          super(ex.message)
          @wrapped_exception = ex

        elsif ex.respond_to?(:status_code)
          begin
            # try to parse response body to retreive more detailed API error message
            result = Parser.parse(ex.body)
            super("the server responded with status #{ex.status_code} and message \"#{result['message']}\"")
          rescue ParsingError
            super("the server responded with status #{ex.status_code}")
          ensure
            @response = ex
          end

        else
          super(ex.to_s)
        end
      end

      def backtrace
        @wrapped_exception ? @wrapped_exception.backtrace : super
      end

      def inspect
        %(#<#{self.class}: #{@wrapped_exception.class}>)
      end
    end

    class ClientError < ResponseError; end
    class ServerError < ResponseError; end

  end
end
