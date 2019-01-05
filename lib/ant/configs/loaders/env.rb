module Ant
  module Configuration
    module Loaders
      class Env
        include Ant::Configuration::Utils
        def initialize(env_prefix, manager)
          @env_prefix = env_prefix
          @manager = manager
        end

        def load!
          ENV.select { |str| str.start_with?(@env_prefix) }
             .each_with_object({}) do |(k, v), h|
               clean_key = k.sub(/^#{@env_prefix}_?/, '').downcase.split('__')
               recursive_set(h, clean_key, split_env_string(v))
             end
        end
      end
    end
  end
end
