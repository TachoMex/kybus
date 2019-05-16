module Ant
  module Configs
    module Autoconfigs
      extend Ant::DRY::ResourceInjector

      def self.from_config(adapter, config)
        require_relative "autoconfigs/#{adapter}" unless resource?(adapter)

        factory = resource(adapter)
        factory.from_config(config)
      end
    end
  end
end
