# frozen_string_literal: true

# TODO: Comming soon!

require 'ant/core'

module Ant
  module Configuration
    # Allow to autoload configurations into ruby.
    # It allows to implement new plugins.
    class ServiceManager
      extend Ant::DRY::ResourceInjector
      def initialize(configs)
        @configs = configs
      end

      def self.auto_load!(test_connections: false)
        @configs = Ant::Configuration::ConfigurationManager.auto_load!
      end

      def register_plugin(name); end
    end
  end
end
