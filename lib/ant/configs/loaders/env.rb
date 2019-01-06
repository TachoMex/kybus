module Ant
  module Configuration
    module Loaders
      # This class allows to load configurations from ENV
      # It requires that all the vars are named with a common prefix
      # It uses '__' as a delimiter to allow nested configurations
      # === Examples
      #   export CONFIG_ENV_VALUE=3 => { 'env_value' => '3' }
      #   export CONFIG_ENV_OBJ__VALUE=3 => { "env_obj" => { 'value' => '3' } }
      class Env
        include Ant::Configuration::Utils
        def initialize(env_prefix, manager)
          @env_prefix = env_prefix
          @manager = manager
        end

        # Parses the configurations from ENV
        def load!
          ENV.select { |str| str.start_with?(@env_prefix) }
             .each_with_object({}) do |(k, v), h|
               # Remove ENV prefix and conver to downcase, then split by '__'
               clean_key = k.sub(/^#{@env_prefix}_?/, '').downcase.split('__')
               # recursively create the objects to set the config where it
               # should be
               recursive_set(h, clean_key, split_env_string(v))
             end
        end
      end
    end
  end
end
