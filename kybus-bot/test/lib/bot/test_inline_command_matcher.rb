# frozen_string_literal: true

require './test/test_helper'
require './lib/kybus/bot/command/inline_command_matcher'
require './lib/kybus/bot/command/command_definition'

module Kybus
  module Bot
    class TestInlineCommandMatcher < Minitest::Test
      def setup
        @definitions = Kybus::Bot::CommandDefinition.new
      end

      def test_match_string_with_inline_args
        @definitions.register_command('/hello', [])
        matcher = Kybus::Bot::InlineCommandMatcher.new(@definitions)
        command, args = matcher.find_command_with_inline_arg('/hello8__a')
        assert_equal('/hello', command.name)
        assert_equal(%w[8 a], args)
      end

      def test_match_class
        @definitions.register_command(String, [])
        matcher = Kybus::Bot::InlineCommandMatcher.new(@definitions)
        command, args = matcher.find_command_with_inline_arg('anything')
        assert_equal(String, command.name)
        assert_equal([], args)
      end

      def test_match_regexp
        @definitions.register_command(/\/hi\d+/, [])
        matcher = Kybus::Bot::InlineCommandMatcher.new(@definitions)
        command, args = matcher.find_command_with_inline_arg('/hi123')
        assert_equal('/hi123', command.name)
        assert_equal(['/hi123'], args)
      end
    end
  end
end
