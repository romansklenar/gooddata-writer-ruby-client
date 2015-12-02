require "ostruct"

module Keboola
  module GoodDataWriter

    class Job < OpenStruct
      def ok?
        %w[ok].include?(status)
      end

      def success?
        %w[success].include?(status)
      end

      def finished?
        %w[cancelled success error warning terminated].include?(status)
      end

      def pending?
        %w[waiting processing terminating].include?(status)
      end

      def error?
        %w[cancelled error terminated].include?(status)
      end
    end

  end
end
