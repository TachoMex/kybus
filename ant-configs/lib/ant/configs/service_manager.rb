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

      def initialize(configs, plugin_subdir = '.')
        @configs = configs
        @services = {}
        @plugin_subdir = plugin_subdir
      end

      def services(cathegory, name)
        @services[cathegory][name].raw
      end

      def all_services
        @services
      end

      def configure!
        plugins = self.class.resources(:plugins)
        plugins.each do |plug, type|
          case type
          when 'unique'
            @services[plug] = Ant::Configuration::Autoconfigs.from_config!(plug, @configs[plug])
          else
            load_service!(plug, @configs[plug])
          end
        end
      end

      def load_service!(name, keys)
        return if keys&.empty?

        services = {}
        keys.each do |service, config|
          services[service] = build_service(name, config)
        end

        @services[name] = services
      end

      def build_service(name, config)
        Ant::Configuration::Autoconfigs.from_config!(name, config, @plugin_subdir)
      end

      def self.auto_load!
        configs = Ant::Configuration::ConfigurationManager.auto_load!
        services = new(configs)
        services.configure!
        services
      end

      # The type unique is for global configurations as multi is for a hash
      # containing all the objects to be created
      def self.register_plugin(name, type = 'multi')
        register(:plugins, name, type)
      end

      register_plugin('sequel')
      register_plugin('aws', 'unique')
      register_plugin('logger', 'unique')
    end
  end
end
