# frozen_string_literal: true

module Kybus
  module Configuration
    module Loaders
      # This class allows to load configurations from ARGV
      # It requires that all the vars are named with a common prefix
      # It uses '__' as a delimiter to allow nested configurations
      # - If the arg contains an '=' sym it will take the left string as key
      #   and the right as the value
      # - If the arg does not contain an '=' it will take the next arg as value
      # - If the next arg to an arg is also an arg, it will parse it as a flag.
      # - Also if the last element of ARGV is an arg it will
      #   be parsed as a flag.
      # === Examples
      #   --config_env_value=3 => { 'env_value' => '3' }
      #   --config_env_value 3 => { 'env_value' => '3' }
      #   --config_env_obj__value 3 => { "env_obj" => { 'value' => '3' } }
      #   --config_flag --config_value 3 => { 'flag' => 'true', value => '3' }
      class Arg
        include Kybus::Configuration::Utils
        def initialize(env_prefix, manager, array = ARGV)
          @env_prefix = env_prefix.downcase
          @manager = manager
          @array = array
        end

        # Parses configurations from array and returns the value as a hash
        def load!
          configs = {}
          @array.each_with_index do |obj, idx|
            next unless obj.start_with?('--' + @env_prefix)

            value = extract_value(obj, idx + 1)
            key = obj.split('=').first
                     .sub(/^--#{@env_prefix}_?/, '')
                     .downcase.split('__')
            recursive_set(configs, key, split_env_string(value))
          end
          configs
        end

        # Parses a string as described above
        def extract_value(string, idx)
          if string.include?('=')
            string.split('=')[1]
          elsif @array.size == idx
            'true'
          elsif @array[idx].start_with?('--')
            'true'
          else
            @array[idx]
          end
        end
      end
    end
  end
end
