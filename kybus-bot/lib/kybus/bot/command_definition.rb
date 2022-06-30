# frozen_string_literal: true

module Kybus
  module Bot
    # Object that wraps a command, it is analogus to a route definition.
    # it currently only gets a param list, but it will be extended to a more
    # complex DSL.
    class Command
      attr_reader :block

      # Receives a list of params as symbols and the lambda with the block.
      def initialize(params, &block)
        @params = params
        @block = block
      end

      # Checks if the params object given contains all the needed values
      def ready?(current_params)
        @params.all? { |key| current_params.key?(key) }
      end

      # Finds the first empty param from the given parameter
      def next_missing_param(current_params)
        @params.find { |key| !current_params.key?(key) }
      end
    end

    # Wraps a collection of commands.
    class CommandDefinition
      def initialize
        @commands = {}
      end

      # Stores an operation definition
      def register_command(name, params, &block)
        @commands[name] = Command.new(params, &block)
      end

      def registered_commands
        @commands.keys
      end

      # Returns a command with the name
      def [](name)
        @commands[name]
      end
    end
  end
end
