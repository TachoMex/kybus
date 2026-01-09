# frozen_string_literal: true

require './test/test_helper'
require './lib/kybus/bot/migrator'
require 'tmpdir'

module Kybus
  module Bot
    class TestMigrator < Minitest::Test
      def test_sequel_migrator_creates_table
        Dir.mktmpdir do |dir|
          db_path = File.join(dir, 'bot.db')
          config = { 'name' => 'sequel', 'endpoint' => "sqlite://#{db_path}" }
          Kybus::Bot::Migrator.run_migrations!(config)
          db = Sequel.connect(config['endpoint'])
          columns = db.schema(:bot_sessions).map(&:first).map(&:to_s)
          %w[channel_id user params metadata files cmd requested_param last_message].each do |col|
            assert_includes(columns, col)
          end
        end
      end

      def test_dynamoid_migrator_creates_table_when_missing
        unless Object.const_defined?(:Dynamoid)
          Object.const_set(:Dynamoid, Module.new)
        end
        Dynamoid.singleton_class.send(:define_method, :adapter) do
          @adapter ||= Object.new
        end
        adapter = Dynamoid.adapter
        adapter.define_singleton_method(:list_tables) { [] }

        repo = mock
        model_class = mock
        model_class.expects(:create_table).with(sync: true)
        repo.stubs(:model_class).returns(model_class)
        Kybus::Storage::Datasource::DynamoidRepository.expects(:from_config).returns(repo)

        config = {
          'name' => 'dynamoid',
          'access_key' => 'x',
          'secret_key' => 'y',
          'region' => 'us-east-1',
          'endpoint' => 'http://localhost:8000',
          'namespace' => 'kybus'
        }
        Kybus::Bot::Migrator.run_migrations!(config)
      end

      def test_dynamoid_migrator_skips_when_table_exists
        unless Object.const_defined?(:Dynamoid)
          Object.const_set(:Dynamoid, Module.new)
        end
        Dynamoid.singleton_class.send(:define_method, :adapter) do
          @adapter ||= Object.new
        end
        adapter = Dynamoid.adapter
        adapter.define_singleton_method(:list_tables) { ['bot_sessions'] }

        repo = mock
        model_class = mock
        model_class.expects(:create_table).never
        repo.stubs(:model_class).returns(model_class)
        Kybus::Storage::Datasource::DynamoidRepository.expects(:from_config).returns(repo)

        config = {
          'name' => 'dynamoid',
          'access_key' => 'x',
          'secret_key' => 'y',
          'region' => 'us-east-1',
          'endpoint' => 'http://localhost:8000',
          'namespace' => 'kybus'
        }
        Kybus::Bot::Migrator.run_migrations!(config)
      end

      def test_unknown_provider_raises
        assert_raises(RuntimeError) { Kybus::Bot::Migrator.run_migrations!('name' => 'unknown') }
      end
    end
  end
end
