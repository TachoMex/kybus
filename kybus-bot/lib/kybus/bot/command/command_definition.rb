# frozen_string_literal: true

require_relative 'command'

module Kybus
  module Bot
    class CommandDefinition
      def initialize
        @commands = {}
      end

      # Stores an operation definition
      def register_command(name, params, &)
        @commands[name] = Command.new(name, params, &)
      end

      def registered_commands
        @commands.keys
      end

      def each(&)
        @commands.each(&)
      end

      # Returns a command with the name
      def [](name)
        @commands[name]
      end
    end
  end
end
