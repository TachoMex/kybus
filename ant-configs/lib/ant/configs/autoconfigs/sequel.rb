# frozen_string_literal: true

module Ant
  module Configuration
    module Autoconfigs
      class Sequel
        def self.from_config(config)
          require 'sequel'
          new(config)
        end

        def initialize(config)
          @config = config
          @connection = ::Sequel.connect(config['endpoint'], config)
        end

        def sanity_check
          @connection.fetch('select 1 + 1;')
        end

        def raw
          @connection
        end

        def help
          CONFIG_KEYS
        end
      end

      register('sequel', Sequel)
    end
  end
end
