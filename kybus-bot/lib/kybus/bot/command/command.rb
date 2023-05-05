# frozen_string_literal: true

module Kybus
  module Bot
    # Object that wraps a command, it is analogus to a route definition.
    # it currently only gets a param list, but it will be extended to a more
    # complex DSL.
    class Command
      attr_reader :block, :params, :name
      attr_writer :name
      # Receives a list of params as symbols and the lambda with the block.
      def initialize(name, params_config, &block)
        @name = name
        @block = block
        case params_config
        when Array
          @params = params_config
          @params_config = {}
        when Hash
          @params = params_config.keys
          @params_config = params_config
        end
      end

      # Checks if the params object given contains all the needed values
      def ready?(current_params)
        params.all? { |key| current_params.key?(key) }
      end

      # Finds the first empty param from the given parameter
      def next_missing_param(current_params)
        params.find { |key| !current_params.key?(key) }.to_s
      end

      def params_ask_label(param)
        @params_config[param.to_sym]
      end

      def params_size
        @params.size
      end
    end
  end
end
