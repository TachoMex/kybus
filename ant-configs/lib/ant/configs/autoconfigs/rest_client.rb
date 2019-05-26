module Ant
  module Configuration
    module Autoconfigs
      class RESTClient
        include Ant::Configuration::Utils

        def self.from_config(config)
          require 'ant/client'
          new(config)
        end

        def initialize(config)
          @config = config
          @connection = Ant::Client::RESTClient.new(symbolize(config))
        end

        def sanity_check
          true
        end

        def raw
          @connection
        end
      end

      register('rest_client', RESTClient)
    end
  end
end
