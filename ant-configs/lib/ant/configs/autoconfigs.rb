module Ant
  module Configuration
    module Autoconfigs
      extend Ant::DRY::ResourceInjector

      def self.from_config!(adapter, config)
        require_relative "autoconfigs/#{adapter}"

        factory = resource(adapter)
        factory.from_config(config)
      end
    end

    def self.auto_load!
      Ant::Configuration::ServiceManager.auto_load!
    end
  end
end
