# frozen_string_literal: true

module Kybus
  module Configuration
    class ConfigurationValidator
      # Exception raised when a configuration was not set
      class MissingConfigs < StandardError
        # Keys that were not loaded correctly
        attr_reader :keys

        def initialize(keys)
          @keys = keys
          super('There are keys missing to be configured')
        end

        def show_missing_keys_error
          # :nocov:
          puts "You are missing some configs!\nAdd them to a file and export the config env var.\n" \
               "Maybe you just need to add them to your existing files\nMissing configs:\n-"
          puts keys.join("\n- ")
          # :nocov:
        end
      end

      def initialize(configs, placeholder)
        @configs = configs
        @placeholder = placeholder
      end

      def missing_configs_from_hash(hash = @configs, path = [])
        hash.map { |k, v| missing_configs(v, path + [k]) }.flatten
      end

      def missing_configs_from_array(array = @configs, path = [])
        array.map.with_index { |conf, idx| missing_configs(conf, path + [idx]) }.flatten
      end

      # Looks for keys having the default placeholder, which are meant to be
      # missing configurations
      def missing_configs(hash = @configs, path = [])
        case hash
        when Hash
          missing_configs_from_hash(hash, path)
        when Array
          missing_configs_from_array(hash, path)
        else
          hash == @placeholder ? [path.join('.')] : []
        end
      end

      def validate!
        missing = missing_configs(@configs)
        raise MissingConfigs, missing unless missing.empty?

        true
      end
    end
  end
end
