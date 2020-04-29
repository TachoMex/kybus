# frozen_string_literal: true

module Kybus
  module Configuration
    module Autoconfigs
      extend Kybus::DRY::ResourceInjector

      def self.from_config!(adapter, config, loading_path = '.')
        require_relative "autoconfigs/#{loading_path}/#{adapter}"

        factory = resource(adapter)
        factory.from_config(config)
      end
    end

    def self.auto_load!
      Kybus::Configuration::ServiceManager.auto_load!
    end
  end
end
