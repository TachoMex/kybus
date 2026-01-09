# frozen_string_literal: true

module Kybus
  module Bot
    # Matches commands with inline args (e.g. /cmd1__2).
    class InlineCommandMatcher
      def initialize(definitions)
        @definitions = definitions
        @matchers = build_matchers
      end

      def find_command_with_inline_arg(name_with_arg)
        @definitions.each do |name, command|
          matcher = @matchers[name.class]
          result = matcher&.call(name, command, name_with_arg)
          return result if result
        end
        nil
      end

      private

      def build_matchers
        {
          Class => method(:match_inline_class),
          String => method(:match_inline_string),
          Regexp => method(:match_inline_regexp)
        }
      end

      def match_inline_class(name, command, name_with_arg)
        [command, []] if name_with_arg.is_a?(name)
      end

      def match_inline_string(name, command, name_with_arg)
        [command, name_with_arg.gsub(name, '').split('__')] if name_with_arg.start_with?(name)
      end

      def match_inline_regexp(name, command, name_with_arg)
        return unless name_with_arg.match?(name)

        storable_command = command.dup
        storable_command.name = name_with_arg
        [storable_command, [name_with_arg]]
      end
    end
  end
end
