module Ant
  module Configuration
    module Loaders
      class Arg
        include Ant::Configuration::Utils
        def initialize(env_prefix, manager, array = ARGV)
          @env_prefix = env_prefix.downcase
          @manager = manager
          @array = array
        end

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
