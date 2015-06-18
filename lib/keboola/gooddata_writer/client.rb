require "hurley"

module Keboola
  module GoodDataWriter

    class Client < ::Hurley::Client
      def self.factory(endpoint:, token:)
        client = new(endpoint)
        client.header[:x_storageapi_token] = token
        client.header[:accept] = "application/json"
        client.request_options.redirection_limit = 5
        client.request_options.timeout = 5
        client
      end
    end

  end
end
