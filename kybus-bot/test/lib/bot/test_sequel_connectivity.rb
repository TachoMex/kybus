# frozen_string_literal: true

require './test/test_helper'

module Kybus
  module Bot
    class TestSequelConnectivity < Minitest::Test
      def setup
        path = 'storage/bot.db'
        endpoint = "sqlite://#{path}"
        File.delete(path) if File.file?(path)
        Kybus::Bot::Migrator.run_migrations!(Sequel.connect(endpoint))
        conf = CONFIG.dup
        conf['state_repository'] = {
          'name' => 'sequel',
          'endpoint' => endpoint
        }
        @sequel_bot = Kybus::Bot::Base.new(conf)
        @sequel_bot.register_command('/remindme', %i[what when]) do
          assert_command('/remindme', params[:what], params[:when])
        end
      end

      def test_sequel_connectivity
        @sequel_bot.expects(:assert_command)
                   .with('/remindme', 'to get eggs', '2019-03-11 12:00 everyday')
        @sequel_bot.expects(:assert_command)
                   .with('/remindme', 'to take the pills', '2019-03-11 23:00 everyday')
        assert @sequel_bot.run_test
      end
    end
  end
end
