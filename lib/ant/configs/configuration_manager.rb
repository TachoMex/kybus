require 'ant/dry/resource_injector'
require_relative 'utils'
require_relative 'loaders/yaml'
require_relative 'loaders/env'
require_relative 'loaders/arg'

module Ant
  module Configuration
    # This class provides a module for loading configurations from 4 sources:
    # - YAML default files
    # - YAML files
    # - ENV vars
    # - ARGV values
    # Using yaml defaults:
    # TODO: Add docs
    # Using yaml files
    # TODO: Add docs
    # Using env vars:
    # TODO: Add docs
    # Using arg vars:
    # TODO: Add docs
    class ConfigurationManager
      include Utils
      # [String(Array)] A path to default yaml configs.
      attr_reader :default_files
      # [String] The value provided by default. It should mean this \
      # value is missing on configurations.
      attr_reader :default_placeholder
      # With this enabled all array will be concatenated instead of replaced.
      attr_reader :append_arrays
      # Use this configuration when you don't want your configs to be validated.
      attr_reader :accept_default_keys
      # The prefix used to find env strings and args.
      attr_reader :env_prefix

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
        # TODO: Implement this
      end

      def pretty_load_configs!
        load_configs!
        # TODO: Implement this. Call load_configs! and display pretty error
      end

      # returns the object as a hash
      def to_h
        @configs
      end

      # provide a method for accessing configs
      def [](key)
        @configs[key]
      end

      # TODO: set private methods
      # private

      # Path to config files
      def env_files
        array_wrap(@env_vars['files'])
      end

      # Extract vars from env
      def env_vars
        Loaders::Env.new(@env_prefix, self).load!
      end

      # Extract vars from arg
      def arg_vars
        Loaders::Arg.new(@env_prefix, self).load!
      end

      # Helper method that loads configurations
      def load_configs
        load_default_files
        load_config_files
        @configs = recursive_merge(@configs, @env_vars)
        @configs = recursive_merge(@configs, arg_vars)
      end

      # Helper method for loading default files
      def load_default_files
        load_files(@default_files)
      end

      # Helper method for loading config files
      def load_config_files
        load_files(@config_files)
      end

      # Helper method for loading files into configurations
      def load_files(files)
        files.each do |file|
          config = Loaders::YAML.new(file, self).load!
          @configs = recursive_merge(@configs, config)
        end
      end
    end
  end
end
