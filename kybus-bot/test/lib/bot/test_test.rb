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

      def test_unit_test_adapter
        @bot.expects(:assert_command)
            .with('/remindme', 'to get eggs', '2019-03-11 12:00 everyday')
        @bot.receives('/remindme')
        @bot.receives('to get eggs')
        @bot.receives('2019-03-11 12:00 everyday')
      end
    end
  end
end
