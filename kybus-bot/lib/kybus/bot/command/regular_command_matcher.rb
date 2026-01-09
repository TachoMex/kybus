# frozen_string_literal: true

module Kybus
  module Bot
    # Matches commands by exact name, regex, or class.
    class RegularCommandMatcher
      def initialize(definitions)
        @definitions = definitions
        @matchers = build_matchers
      end

      def find_command(search)
        @definitions.each do |name, command|
          matcher = @matchers[name.class]
          result = matcher&.call(name, command, search)
          return result if result
        end
        nil
      end

      private

      def build_matchers
        {
          String => method(:match_string),
          Class => method(:match_class),
          Regexp => method(:match_regexp)
        }
      end

      def match_string(name, command, search)
        command if name == search
      end

      def match_class(name, command, search)
        command if search.is_a?(name)
      end

      def match_regexp(name, command, search)
        return unless search.is_a?(String) && name.match?(search)

        storable_command = command.clone
        storable_command.name = search
        storable_command
      end
    end
  end
end
