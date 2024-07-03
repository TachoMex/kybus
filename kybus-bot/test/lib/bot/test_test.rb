# frozen_string_literal: true

require './test/test_helper'
require './lib/kybus/bot/test'

module Kybus
  module Bot
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

      def test_inline_args
        bot = ::Kybus::Bot::Base.make_test_bot('inline_args' => true)
        bot.register_command('/hello', %i[number]) do
          confirm(params[:number])
        end
        bot.expects(:confirm).with('8')
        bot.receives('/hello8')
      end

      def test_inline_multi_args
        bot = ::Kybus::Bot::Base.make_test_bot('inline_args' => true)
        bot.register_command('/hello', %i[number letter]) do
          confirm(params[:number], params[:letter])
        end
        bot.expects(:confirm).with('8', 'a')
        bot.receives('/hello8__a')
      end

      def test_inline_args_regular_command
        bot = ::Kybus::Bot::Base.make_test_bot('inline_args' => true)
        bot.register_command('/hello') do
          confirm
        end
        bot.expects(:confirm)
        bot.receives('/hello')
      end

      def test_inline_args_default_command
        bot = ::Kybus::Bot::Base.make_test_bot('inline_args' => true)
        bot.register_command('default') do
          confirm
        end
        bot.expects(:confirm)
        bot.receives('/hello99')
      end

      def test_precommand_hooks
        @bot.precommand_hook { send_message('prehook') }
        %w[/hello /start /new].each do |cmd|
          @bot.register_command(cmd) {}
          @bot.expects(:send_message).with('prehook')
          @bot.receives(cmd)
        end
      end

      def test_redirect
        @bot.register_command('/hello') do
          redirect('/other', 2)
        end

        @bot.register_command('/other', %i[number]) do
          send_message("Hello #{params[:number]}")
        end

        @bot.expects(:send_message).with('Hello 2')
        @bot.receives('/hello')
      end

      def test_check_metadata_storage
        token = (1..100).to_a.sample
        @bot.register_command('/set_metadata') do
          metadata[:info] = { token:, hello: 'world' }
        end

        @bot.register_command('/validate') do
          raise 'Invalid Token' if metadata[:info][:token] != token
          raise 'Invalid metadatada' if metadata[:info][:hello] != 'world'
        end

        @bot.receives('/set_metadata')
        @bot.receives('/validate')
      end

      def test_abort_with_message
        @bot.register_command('/abort') do
          abort('Stop execution')
          send_message('Not really expected')
        end
        @bot.expects(:send_message).with('Stop execution').once
        @bot.receives('/abort')
      end

      def test_abort_without_message
        @bot.register_command('/abort') do
          abort
          send_message('Not really expected')
        end
        @bot.expects(:send_message).never
        @bot.receives('/abort')
      end
    end
  end
end
