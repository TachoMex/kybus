# frozen_string_literal: true

require_relative 'test_test'

module Kybus
  module Bot
    class SidekiqWorker
      def self.perform_async(state)
        Kybus::Bot::SidekiqWorker.new.perform(state)
      end
    end

    class TestSidekiq < Minitest::Test
      def setup
        @bot = ::Kybus::Bot::Base.make_test_bot('sidekiq' => true)
        @bot.register_command('/reply') do
          raise if last_message.reply?

          assert_command(:done)
        end

        @bot.register_command('/channel_id') do
          send_message(last_message.channel_id)
        end
      end

      def test_sidekiq_reply
        DSLMethods.any_instance.expects(:assert_command).with(:done)
        @bot.receives('/reply')
      end

      def test_sidekiq_channel_id
        DSLMethods.any_instance.expects(:send_message).with(kind_of(String))
        @bot.receives('/channel_id')
      end

      def test_sidekiq_redirect_no_params
        @bot.register_command('/redirect') do
          redirect('/test')
        end

        @bot.register_command('/test') do
          assert_command(:done)
        end

        DSLMethods.any_instance.expects(:assert_command).with(:done)
        @bot.receives('/redirect')
      end
    end
  end
end
