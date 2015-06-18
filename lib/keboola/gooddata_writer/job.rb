require "ostruct"

module Keboola
  module GoodDataWriter

    class Job < OpenStruct
      def success?
        %w[success ok].include?(status)
      end

      def finished?
        %w[cancelled success error warning terminated].include?(status)
      end

      def pending?
        %w[waiting processing terminating].include?(status)
      end
    end

  end
end
