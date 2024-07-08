# frozen_string_literal: true

require './test/test_helper'
require './lib/kybus/bot/test'

module Kybus
  module Bot
    class TestForkers < Minitest::Test
      def setup
        @bot = ::Kybus::Bot::Base.make_test_bot
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
    end
  end
end
