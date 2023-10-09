# frozen_string_literal: true

require 'kybus/core'
require_relative 'feature_flag'
require_relative 'utils'
require_relative 'config_validator'
require 'forwardable'

module Kybus
  module Configuration
    class ConfigurationManager
      extend Kybus::DRY::ResourceInjector
      extend Forwardable
      include Utils
      attr_reader :metaconfigs

      Metaconfig = Struct.new(:default_files, :default_placeholder, :append_arrays, :env_prefix, :accept_default_keys)

      def_delegators :@metaconfigs, :default_files, :env_prefix, :default_placeholder, :accept_default_keys
      def_delegator :@configs, :[]
      def_delegator :@configs, :to_h

      def self.register_config_provider(provider)
        providers = unsafe_resource(:providers) || []
        providers << provider
        register(:providers, providers)
      end

      def initialize(default_files:,
                     default_placeholder: nil,
                     append_arrays: false,
                     env_prefix: nil,
                     accept_default_keys: false)
        @metaconfigs = Metaconfig.new(
          array_wrap(default_files),
          default_placeholder || 'REPLACE_ME',
          append_arrays,
          env_prefix || 'CONFIG',
          accept_default_keys
        )

        @configs = Loaders::FilesLoader.new(default_files).load!
      end

      # Loads the configurations from all the possible sources. It will raise an
      # exception when it is required to validate that no default placeholder
      # is present on the configs.
      def load_configs!
        load_configs
        validator = ConfigurationValidator.new(@configs, default_placeholder)
        return self if accept_default_keys || validator.validate!
      end

      # Use this when you require the application to do not start when something
      # is missing and the error message should be displayed in stdout.
      # This is helpful when you are launching your app and you need to trace
      # any misconfiguration problem.
      # :nocov: #
      def pretty_load_configs!(terminate = true)
        load_configs!
      rescue ::Kybus::Configuration::ConfigurationValidator::MissingConfigs => e
        e.show_missing_keys_error
        exit(1) if terminate
      end
      # :nocov: #

      def self.auto_load!
        auto_configs = new(default_files: './config/autoconfig.yaml').load_configs!['autoconfig']
        configs = new(
          default_files: auto_configs.fetch('default_files', []) +
                         auto_configs.fetch('files', []) +
                         ['./config/autoconfig.yaml'],
          default_placeholder: auto_configs['default_placeholder'],
          accept_default_keys: auto_configs['accept_default_keys'],
          env_prefix: auto_configs['env_prefix']
        )
        if auto_configs['pretty_load']
          configs.pretty_load_configs!
        else
          configs.load_configs!
        end
        configs
      end

      private

      # Helper method that loads configurations
      def load_configs
        self.class.resource(:providers).each do |provider|
          loader = provider.new(env_prefix)
          @configs = recursive_merge(@configs, loader.load!)
        end
      end
    end
  end
end

require_relative 'loaders/env'
require_relative 'loaders/yaml'
require_relative 'loaders/arg'
