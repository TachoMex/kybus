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

      # Loads the configurations from all the possible sources. It will raise an
      # exception when it is required to validate that no default placeholder
      # is present on the configs.
      def load_configs!
        load_configs
        missing_keys = missing_configs
        return if missing_keys.empty? || @accept_default_keys

        raise MissingConfigs, missing_keys
      end

      # Use this when you require the application to do not start when something
      # is missing and the error message should be displayed in stdout.
      # This is helpful when you are launching your app and you need to trace
      # any misconfiguration problem.
      def pretty_load_configs!(terminate = true)
        load_configs!
      rescue MissingConfigs => ex
        puts 'You are missing some configs!'
        puts 'Add them to a file and export the config env var:'
        puts "$ export #{@env_prefix}_FILES='#{Dir.pwd}'/config/config.yaml"
        puts 'Maybe you just need to add them to your existing files'
        puts 'Missing configs:'
        ex.keys.each { |k| puts "- \"#{k}\"" }
        exit(1) if terminate
      end

      # returns the object as a hash
      def to_h
        @configs
      end

      # provide a method for accessing configs
      def [](key)
        @configs[key]
      end

      private

      # Looks for keys having the default placeholder, which are meant to be
      # missing configurations
      def missing_configs(hash = @configs, path = [])
        case hash
        when Hash
          hash.map { |k, v| missing_configs(v, path + [k]) }.flatten
        when Array
          hash.map.with_index { |e, i| missing_configs(e, path + [i]) }.flatten
        else
          hash == @default_placeholder ? [path.join('.')] : []
        end
      end

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

      # Exception raised when a configuration was not set
      class MissingConfigs < StandardError
        # Keys that were not loaded correctly
        attr_reader :keys

        def initialize(keys)
          @keys = keys
          super('There are keys missing to be configured')
        end
      end
    end
  end
end
