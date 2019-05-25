# frozen_string_literal: true

# TODO: Comming soon!

require 'ant/core'

module Ant
  module Configuration
    # Allow to autoload configurations into ruby.
    # It allows to implement new plugins.
    class ServiceManager
      extend Ant::DRY::ResourceInjector
      attr_reader :configs

      def initialize(configs)
        @configs = configs
        @services = {}
      end

      def services(cathegory, name)
        @services[cathegory][name].raw
      end

      def all_services
        @services
      end

      def configure!
        plugins = self.class.resources(:plugins)
        plugins.each do |plug, _|
          load_service!(plug, @configs[plug])
        end
      end

      def load_service!(name, keys)
        return if keys&.empty?

        services = {}
        keys.each do |service, config|
          services[service] = Ant::Configuration::Autoconfigs.from_config!(name, config)
        end

        @services[name] = services
      end

      def self.auto_load!
        configs = Ant::Configuration::ConfigurationManager.auto_load!
        services = new(configs)
        services.configure!
        services
      end

      def self.register_plugin(name)
        # storing a 1 since it will to store the value name in the root plugins
        register(:plugins, name, 1)
      end

      register_plugin('sequel')
    end
  end
end
