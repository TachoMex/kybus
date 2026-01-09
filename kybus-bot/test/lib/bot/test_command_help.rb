# frozen_string_literal: true

require './test/test_helper'
require './lib/kybus/bot/test'

module Kybus
  module Bot
    class TestCommandHelp < Minitest::Test
      def setup
        Kybus::Bot::Base.enable_command_help!
        @bot = ::Kybus::Bot::Base.make_test_bot
      end

      def test_help_overview_includes_command_and_hint
        @bot.register_command('/hello', %i[name], hint: 'Say hi') { send_message('ok') }
        @bot.expects(:send_message).with do |msg|
          assert(msg.include?('/hello'))
          assert(msg.include?('<name>'))
          assert(msg.include?('Say hi'))
        end
        @bot.receives('/help')
      end

      def test_help_command_details
        @bot.register_command('/ping', hint: 'Ping command') { send_message('pong') }
        @bot.expects(:send_message).with do |msg|
          assert(msg.include?('/ping'))
          assert(msg.include?('Ping command'))
          assert(msg.include?('/help_ping'))
        end
        @bot.receives('/help_ping')
      end
    end
  end
end
