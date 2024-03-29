# frozen_string_literal: true

module Kybus
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

        def raw
          @connection
        end
      end

      register('sequel', Sequel)
    end
  end
end
