# frozen_string_literal: true

require './test/test_helper'
require './lib/kybus/bot/test'

module Kybus
  module Bot
    class TestTest < Minitest::Test
      def setup
        @bot = ::Kybus::Bot::Base.make_test_bot
        register_default_commands
      end

      def register_default_commands
        @bot.register_command('/remindme', %i[what when]) { assert_command('/remindme', params[:what], params[:when]) }
      end

      def test_bot_has_registered_commands
        refute(@bot.registered_commands.empty?)
      end

      def test_reject_empty_messages
        @bot.register_command('/empty') { send_message(nil) }
        assert_raises(::Kybus::Bot::Base::EmptyMessageError) { @bot.receives('/empty') }
      end

      def test_unit_test_adapter
        @bot.expects(:assert_command).with('/remindme', 'to get eggs', '2019-03-11 12:00 everyday')
        simulate_receives('/remindme', 'to get eggs', '2019-03-11 12:00 everyday')
      end

      def test_receiving_file
        @bot.register_command('/file', %i[file file2]) do
          received
          send_message(file(:file).download)
        end
        @bot.expects(:received).once
        @bot.expects(:send_message).with("hello-bot\n")
        @bot.receives('/file')
        @bot.receives('hello', 'file.txt')
        @bot.receives('hello', 'file.txt')
      end

      def test_current_user
        @bot.register_command('/whoami') { send_message(current_user) }
        @bot.expects(:send_message).with('debug_message__testing')
        @bot.receives('/whoami')
      end

      def test_default_command_does_nothing
        @bot.register_command('/do_magic') { send_message('Magic done') }
        @bot.expects(:send_message).never
        # Introduced typo to trigger default command
        @bot.receives('/do_maigc')
      end

      def test_inline_args
        bot = create_bot_with_inline_args
        bot.register_command('/hello', %i[number]) { confirm(params[:number]) }
        bot.expects(:confirm).with('8')
        bot.receives('/hello8')
      end

      def test_inline_multi_args
        bot = create_bot_with_inline_args
        bot.register_command('/hello', %i[number letter]) { confirm(params[:number], params[:letter]) }
        bot.expects(:confirm).with('8', 'a')
        bot.receives('/hello8__a')
      end

      def test_inline_args_regular_command
        bot = create_bot_with_inline_args
        bot.register_command('/hello') { confirm }
        bot.expects(:confirm)
        bot.receives('/hello')
      end

      def test_inline_args_default_command
        bot = create_bot_with_inline_args
        bot.register_command('default') { confirm }
        bot.expects(:confirm)
        bot.receives('/hello99')
      end

      def test_precommand_hooks
        @bot.precommand_hook { send_message('prehook') }
        %w[/hello /start /new].each do |cmd|
          @bot.register_command(cmd) {} # rubocop:disable Lint/EmptyBlock
          @bot.expects(:send_message).with('prehook')
          @bot.receives(cmd)
        end
      end

      private

      def create_bot_with_inline_args
        ::Kybus::Bot::Base.make_test_bot('inline_args' => true)
      end

      def simulate_receives(*messages)
        messages.each { |msg| @bot.receives(msg) }
      end
    end
  end
end
