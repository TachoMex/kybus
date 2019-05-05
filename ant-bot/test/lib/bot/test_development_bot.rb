# frozen_string_literal: true

require './test/test_helper'
require './lib/ant/bot'

module Ant
  module Client
    class TestDevelopmentBot < Minitest::Test
      include Ant::Bot::Adapter

      def setup
        path = 'storage/antbot/debug_message__a.json'
        File.delete(path) if File.file?(path)
        path = 'storage/antbot/debug_message__b.json'
        File.delete(path) if File.file?(path)
        conf = CONFIG
        conf['provider']['echo'] = false

        @bot = Ant::Bot::Base.new(conf)
        @bot.register_command('/remindme', %i[what when]) do |params|
          @bot.assert_command('/remindme', params[:what], params[:when])
        end
      end

      def test_bot
        @bot.expects(:assert_command)
            .with('/remindme', 'to get eggs', '2019-03-11 12:00 everyday')
        @bot.expects(:assert_command)
            .with('/remindme', 'to take the pills', '2019-03-11 23:00 everyday')
        assert_raises(Debug::NoMoreMessageException) { @bot.run }
      end
    end
  end
end
