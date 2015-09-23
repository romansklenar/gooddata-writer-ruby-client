require "hurley"

module Keboola
  module GoodDataWriter

    class Client < ::Hurley::Client
      def self.factory(endpoint: nil, token: nil)
        endpoint || raise(ArgumentError, "endpoint is required")
        token || raise(ArgumentError, "token is required")

        client = new(endpoint)
        client.header[:x_storageapi_token] = token
        client.header[:accept] = "application/json"
        client.request_options.redirection_limit = 5
        client.request_options.timeout = 5
        client.ssl_options.skip_verification = true
        client
      end
    end

  end
end
