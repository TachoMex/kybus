module Ant
  module DRY
    module ResourceInjector
      def resources(key)
        @resources ||= {}
        @resources[key] ||= {}
        @resources[key]
      end

      def register(key, subkey, value = nil)
        if value.nil?
          value = subkey
          subkey = key
          key = :root
        end
        resources(key)[subkey] = value
      end

      def resource(key, subkey = nil)
        if subkey.nil?
          subkey = key
          key = :root
        end
        res = resources(key)[subkey]
        raise("Resource `#{key}::#{subkey}` Not Found") if res.nil?
        res
      end
    end
  end
end
