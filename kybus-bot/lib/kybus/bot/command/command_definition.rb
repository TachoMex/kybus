# frozen_string_literal: true

module Kybus
  module Bot
    class CommandDefinition
      def initialize
        @commands = {}
      end

      # Stores an operation definition
      def register_command(name, params, &block)
        @commands[name] = Command.new(name, params, &block)
      end

      def registered_commands
        @commands.keys
      end

      def each(&block)
        @commands.each(&block)
      end

      # Returns a command with the name
      def [](name)
        @commands[name]
      end
    end
  end
end
