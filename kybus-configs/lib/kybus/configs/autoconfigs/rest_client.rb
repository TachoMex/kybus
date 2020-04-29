# frozen_string_literal: true

module Kybus
  module Configuration
    module Autoconfigs
      class RESTClient
        include Kybus::Configuration::Utils

        def self.from_config(config)
          require 'kybus/client'
          new(config)
        end

        def initialize(config)
          @config = config
          @connection = Kybus::Client::RESTClient.new(symbolize(config))
        end

        def raw
          @connection
        end
      end

      register('rest_client', RESTClient)
    end
  end
end
