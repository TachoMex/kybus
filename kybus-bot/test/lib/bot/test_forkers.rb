# frozen_string_literal: true

require './test/test_helper'
require './lib/kybus/bot/test'

module Kybus
  module Bot
    class TestForkers < Minitest::Test
      QUEUE_URL = 'https://test_queue.com'
      SQS_FORKER_CONFIG = {
        'forker' => { 'provider' => 'sqs', 'queue' => 'TestQueue' }
      }.freeze

      def setup
        make_bot
      end

      def wait_threads
        Thread.list.each do |thread|
          thread.join unless thread == Thread.main || thread.to_s.include?('sleep_forever')
        end
      end

      def make_bot(extra_configs = { 'forker' => { 'provider' => 'thread' } })
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
        wait_threads
      end

      def test_metadata_inside_fork
        @bot.register_job('meta') do
          key = metadata[:key]
          send_message(key)
        end
        @bot.expects(:send_message).with('hellofriend')
        @bot.register_command('/meta') do
          metadata[:key] = 'hellofriend'
          fork_with_delay('meta', 0.2)
        end
        @bot.receives('/meta')
        wait_threads
      end

      def test_fork_with_delay
        @bot.register_command('/sleep') do
          fork_with_delay('fork', 123, a: 'bot', b: 'friend')
        end
        Object.any_instance.expects(:sleep).with(123)
        @bot.expects(:send_message).with('Hello bot, friend')
        @bot.receives('/sleep')
        wait_threads
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

      def mock_sqs_stuff
        sqs = mock
        response = mock
        response.expects(:queue_url).returns(QUEUE_URL)
        sqs.expects(:get_queue_url).with(queue_name: 'TestQueue').returns(response)
        Kybus::Bot::Forkers::LambdaSQSForker.register_queue_client(sqs)
        sqs
      end

      def assert_sqs_handle(sqs)
        sqs.expects(:send_message).with do |event|
          raise 'InvalidQueue' if event[:queue_url] != QUEUE_URL

          json = JSON.parse(event[:message_body], symbolize_names: true)
          @bot.handle_job(json[:job], json[:args], json.dig(:state, :data, :channel_id))
        end
      end

      def test_sqs_forker
        sqs = mock_sqs_stuff
        assert_sqs_handle(sqs)

        make_bot(SQS_FORKER_CONFIG)
        @bot.receives('/fork')
        @bot.receives('bot')
        @bot.dsl.expects(:send_message).with('Hello bot, friend')
        @bot.receives('friend')
        wait_threads
      end
    end
  end
end
