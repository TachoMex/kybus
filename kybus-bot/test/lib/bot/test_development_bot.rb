# frozen_string_literal: true

require './test/test_helper'

module Kybus
  module Bot
    class TestDevelopmentBot < Minitest::Test
      include Kybus::Bot::Adapter

      def setup
        path = 'storage/antbot/debug_message__a.json'
        File.delete(path) if File.file?(path)
        path = 'storage/antbot/debug_message__b.json'
        File.delete(path) if File.file?(path)
        conf = CONFIG.dup
        @bot = Kybus::Bot::Base.new(conf)
        @bot.register_command('/remindme', %i[what when]) do
          assert_command('/remindme', params[:what], params[:when])
        end
      end

      def test_development_bot
        @bot.expects(:assert_command)
            .with('/remindme', 'to get eggs', '2019-03-11 12:00 everyday')
        @bot.expects(:assert_command)
            .with('/remindme', 'to take the pills', '2019-03-11 23:00 everyday')
        assert_raises(Debug::NoMoreMessageException) { @bot.run }
      end

      def test_regexp_commands
        @bot.register_command(/regexp/) { send_message('regexp') }
        @bot.register_command('default') { send_message('/help') }
        @bot.expects(:send_message).with('regexp')
        @bot.receives('regexp')
        @bot.expects(:send_message).with('/help')
        @bot.receives('not regex')
      end

      def test_error_recover
        @bot.rescue_from(StandardError) do
          log_info('Error happened', params[:_last_error])
          send_message('I crashed')
          send_image('dog.jpg')
          send_audio('game_over.mp3')
          send_document('doc.txt')
        end
        @bot.register_command('/crash') do
          raise(StandardError, 'Oh no!')
        end
        @bot.stub_channels('a' => ['/crash'])
        @bot.run_test
      end

      def test_reply
        @bot.expects(:refute).with(false)
        @bot.register_command('/reply') do
          refute(last_message.reply?)
        end
        @bot.receives('/reply')
      end
    end
  end
end
