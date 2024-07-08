# frozen_string_literal: true

require './test/test_helper'
require './lib/kybus/bot/test'

module Kybus
  module Bot
    class TestDSLMethods < Minitest::Test
      def setup
        @bot = ::Kybus::Bot::Base.make_test_bot
        register_default_commands
      end

      def register_default_commands
        @bot.register_command('/remindme', %i[what when]) { assert_command('/remindme', params[:what], params[:when]) }
      end

      def test_is_private
        @bot.register_command('/safe') { send_message(is_private?) }
        @bot.expects(:send_message).with(true)
        @bot.receives('/safe')
      end

      def test_mention
        @bot.register_command('/tag') { send_message(mention(current_user)) }
        @bot.expects(:send_message).with('@debug_message__testing')
        @bot.receives('/tag')
      end

      def test_redirect
        @bot.register_command('/hello') { redirect('/other', 2) }
        @bot.register_command('/other', %i[number]) { send_message("Hello #{params[:number]}") }
        @bot.expects(:send_message).with('Hello 2')
        @bot.receives('/hello')
      end

      def test_wrong_redirect
        @bot.register_command('/hello') { redirect('/other', 2) }
        assert_raises(::Kybus::Bot::Base::BotError) { @bot.receives('/hello') }
      end

      def test_check_metadata_storage
        token = (1..100).to_a.sample
        @bot.register_command('/set_metadata') { metadata[:info] = { token:, hello: 'world' } }
        @bot.register_command('/validate') do
          raise 'Invalid Token' if metadata[:info][:token] != token
          raise 'Invalid metadatada' if metadata[:info][:hello] != 'world'
        end
        simulate_receives('/set_metadata', '/validate')
      end

      def test_abort_with_message
        @bot.register_command('/abort') do
          abort('Stop execution')
          # :nocov:
          send_message('Not really expected') # rubocop:disable Lint/UnreachableCode
          # :nocov:
        end
        @bot.expects(:send_message).with('Stop execution').once
        @bot.receives('/abort')
      end

      def test_abort_without_message
        @bot.register_command('/abort') do
          abort
          # :nocov:
          send_message('Not really expected') # rubocop:disable Lint/UnreachableCode
          # :nocov:
        end
        @bot.expects(:send_message).never
        @bot.receives('/abort')
      end

      def test_command_with_custom_questions
        @bot.register_command('/ask_name', name: 'what is your name?') do
          send_message("hello #{params[:name]}")
        end
        @bot.expects(:send_message).with('what is your name?', 'debug_message__testing')
        @bot.receives('/ask_name')
        @bot.expects(:send_message).with('hello human')
        @bot.receives('human')
      end

      private

      def simulate_receives(*messages)
        messages.each { |msg| @bot.receives(msg) }
      end
    end
  end
end
