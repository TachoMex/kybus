# frozen_string_literal: true

module Ant
  module Bot
    # Implements a factory singleton for building bot adapters
    module Adapter
      extend Ant::DRY::ResourceInjector

      # builds the abstract adapter
      def self.from_config(configs)
        require_relative configs['name']
        resource(configs['name']).new(configs)
      end
    end
  end
end
