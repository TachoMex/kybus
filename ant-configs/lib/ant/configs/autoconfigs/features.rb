# frozen_string_literal: true

module Ant
  module Configuration
    module Autoconfigs
      class Features
        include Ant::Configuration::Utils

        def self.from_config(config)
          new(config)
        end

        def initialize(config)
          @config = config
          @connection = Ant::Configuration::FeatureFlag.new(symbolize(config))
        end

        def [](key)
          @connection[key]
        end
      end

      register('features', Features)
    end
  end
end
