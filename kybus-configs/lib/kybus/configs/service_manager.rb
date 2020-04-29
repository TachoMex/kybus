# frozen_string_literal: true

# TODO: Comming soon!

require 'kybus/core'

module Kybus
  module Configuration
    # Allow to autoload configurations into ruby.
    # It allows to implement new plugins.
    class ServiceManager
      extend Kybus::DRY::ResourceInjector
      attr_reader :configs

      def initialize(configs, plugin_subdir = '.')
        @configs = configs
        @services = {}
        @plugin_subdir = plugin_subdir
      end

      def services(cathegory, name = nil?, sub = nil)
        service = @services[cathegory]
        service = service[name] if service.is_a?(Hash) && name
        service = service[sub] if service.is_a?(Hash) && sub
        service.raw
      end

      def all_services
        @services
      end

      def configure!
        plugins = self.class.resources(:plugins)
        plugins.each do |plug, type|
          next if @configs[plug].nil?

          case type
          when 'unique'
            @services[plug] = Kybus::Configuration::Autoconfigs.from_config!(plug, @configs[plug])
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
        Kybus::Configuration::Autoconfigs.from_config!(name, config, @plugin_subdir)
      end

      def self.auto_load!
        configs = Kybus::Configuration::ConfigurationManager.auto_load!
        services = new(configs)
        services.configure!
        services
      end

      # The type unique is for global configurations as multi is for a hash
      # containing all the objects to be created
      def self.register_plugin(name, type = 'multi')
        register(:plugins, name, type)
      end

      def features
        @services['features']
      end

      register_plugin('aws', 'unique')
      register_plugin('logger', 'unique')
      register_plugin('sequel')
      register_plugin('rest_client')
      register_plugin('features', 'unique')
    end
  end
end
