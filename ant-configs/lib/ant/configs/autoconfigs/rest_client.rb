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
          @connection = Sequel.connect(config)
        end

        def sanity_check
          @connection.fetch('select 1 + 1;')
        end

        def raw
          @connection
        end
      end
    end
  end
end
