module Ant
  module DRY
    ##
    # Provides a method for sending external dependencies
    # to classes, like database connections, configurations,
    # and other objects that can vary but does not modify
    # the class functionality.
    # This class works a decorator to be just extended
    # by classes
    #
    #  class Controller
    #    extend ResourceInjector
    #  end
    module ResourceInjector
      # Initialices the resources value and returns the object.
      # This method should not be used from the out context.
      # Resources are grouped by key
      def resources(key)
        @resources ||= {}
        @resources[key] ||= {}
        @resources[key]
      end

      # Provides the interface for sending objects inside the class.
      # The resources have a group and sub group.
      # When no group is given, it will be added to the :root group
      # ==== Examples
      #   Controller.inject(:magic_number, 42)
      #   Controller.inject(:databases, :database_conection, Sequel.connect)
      def register(key, subkey, value = nil)
        if value.nil?
          value = subkey
          subkey = key
          key = :root
        end
        resources(key)[subkey] = value
      end

      # Provides the inside interface for fetching the objects that were
      # previously provided from the external world.
      # Also, when no subgroup is given, the key is fetched from :root
      # ==== Examples
      #   class Controller
      #     def initialize
      #       @magic_number = self.class.resource(:magic_number)
      #     end
      #
      #     def self.factory(id)
      #       db = resource(:databases, :database_conection)
      #     end
      #   end
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
