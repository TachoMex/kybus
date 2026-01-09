# frozen_string_literal: true

module Kybus
  module Bot
    # Factory for building bot adapters from config.
    module Adapter
      extend Kybus::DRY::ResourceInjector

      # Builds the adapter instance for the given config.
      def self.from_config(configs)
        require_relative configs['name']
        resource(configs['name']).new(configs)
      end
    end
  end
end
