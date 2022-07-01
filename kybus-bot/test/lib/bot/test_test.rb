# frozen_string_literal: true

require './test/test_helper'
require 'kybus/bot/test'

module Kybus
  module Client
    class TestTest < Minitest::Test
      def setup
        @bot = ::Kybus::Bot::Base.make_test_bot
        @bot.register_command('/remindme', %i[what when]) do
          assert_command('/remindme', params[:what], params[:when])
        end
      end

      def test_bot_has_registered_commands
        commands = @bot.registered_commands
        refute(commands.empty?)
      end

      def test_reject_empty_messages
        @bot.register_command('/empty') do
          send_message(nil)
        end
        assert_raises(::Kybus::Bot::Base::EmptyMessageError) { @bot.receives('/empty') }
      end

      def test_unit_test_adapter
        @bot.expects(:assert_command)
            .with('/remindme', 'to get eggs', '2019-03-11 12:00 everyday')
        @bot.receives('/remindme')
        @bot.receives('to get eggs')
        @bot.receives('2019-03-11 12:00 everyday')
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
        @bot.register_command('/whoami') do
          send_message(current_user)
        end
        @bot.expects(:send_message).with('debug_message__testing')
        @bot.receives('/whoami')
      end

      def test_is_private
        @bot.register_command('/safe') do
          send_message(is_private?)
        end
        @bot.expects(:send_message).with(true)
        @bot.receives('/safe')
      end

      def test_mention
        @bot.register_command('/tag') do
          send_message(mention(current_user))
        end
        @bot.expects(:send_message).with('@debug_message__testing')
        @bot.receives('/tag')
      end

      def test_default_command_does_nothing
        @bot.register_command('/do_magic') do
          # :nocov:
          send_message('Magic done')
          # :nocov:
        end
        @bot.expects(:send_message).never
        @bot.receives('/do_maigc')
      end
    end
  end
end
