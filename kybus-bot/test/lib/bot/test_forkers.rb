# frozen_string_literal: true

require './test/test_helper'
require './lib/kybus/bot/test'

module Kybus
  module Bot
    class TestForkers < Minitest::Test
      SQS_FORKER_CONFIG = {
        'forker' => { 'provider' => 'sqs', 'queue' => 'TestQueue' }
      }.freeze

      def setup
        make_bot
      end

      def make_bot(extra_configs = {})
        @bot = ::Kybus::Bot::Base.make_test_bot(extra_configs)
        @bot.register_job('fork', %i[a b]) do
          send_message("Hello #{args[:a]}, #{args[:b]}")
        end
        @bot.register_command('/fork', %i[a b]) do
          fork('fork', { a: params[:a], b: params[:b] })
        end
      end

      def test_fork
        @bot.receives('/fork')
        @bot.receives('bot')
        @bot.expects(:send_message).with('Hello bot, friend')
        @bot.receives('friend')
        sleep(1)
      end

      def test_fork_invalid_job
        assert_raises(Kybus::Bot::Forkers::JobNotFound) do
          @bot.dsl.fork('invalid job', {})
        end
      end

      def test_fork_params_missing
        assert_raises(Kybus::Bot::Forkers::JobNotReady) do
          @bot.dsl.fork('fork', { a: 'hello' })
        end
      end

      def test_sqs_forker
        sqs = mock
        sqs.expects(:get_queue_url).with(queue_name: 'TestQueue').returns('https://test_queue.com')
        sqs.expects(:send_message).with(has_entries(queue_url: 'https://test_queue.com', message_body: anything))
        Kybus::Bot::Forkers::LambdaSQSForker.register_queue_client(sqs)
        make_bot(SQS_FORKER_CONFIG)
        @bot.receives('/fork')
        @bot.receives('hello')
        @bot.receives('world')
      end
    end
  end
end
