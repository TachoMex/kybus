require 'ant/dry/resource_injector'
require_relative 'utils'
require_relative 'loaders/yaml'
require_relative 'loaders/env'

module Ant
  module Configuration
    class ConfigurationManager
      include Utils
      attr_reader :default_files, :default_placeholder, :append_arrays
      attr_reader :accept_default_keys, :env_prefix
      def initialize(default_files:,
                     default_placeholder: 'REPLACE_ME',
                     append_arrays: false,
                     env_prefix: 'CONFIG',
                     accept_default_keys: false)
        @default_files = array_wrap(default_files)
        @default_placeholder = default_placeholder
        @append_arrays = append_arrays
        @env_prefix = env_prefix
        @accept_default_keys = accept_default_keys
        @configs = {}
        @env_vars = env_vars
        @config_files = env_files
      end

      def load_configs!
      end

      def pretty_load_configs!
      end

      # TODO: set private methods
      # private

      def env_files
        array_wrap(@env_vars['files'])
      end

      def to_h
        @configs
      end

      def env_vars
        Loaders::Env.new(@env_prefix, self).load!
      end

      def load_configs
        load_default_files
        load_config_files
        @configs = recursive_merge(@configs, @env_vars)
      end

      def load_default_files
        load_files(@default_files)
      end

      def load_config_files
        load_files(@config_files)
      end

      def load_files(files)
        files.each do |file|
          config = Loaders::YAML.new(file, self).load!
          @configs = recursive_merge(@configs, config)
        end
      end
    end
  end
end
