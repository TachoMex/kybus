# frozen_string_literal: true
module Kybus
  module Bot
    module Migrator
      class << self
        def run_migrations!(config)
          case config['name']
          when 'sequel'
            run_sequel_migrations(config)
          when 'dynamoid'
            run_dynamoid_migrations(config)
          else
            raise "Provider not supported #{config['name']}"
          end
        end

        private

        def run_sequel_migrations(config)
          require 'sequel'
          require 'sequel/extensions/migration'

          conn = Sequel.connect(config['endpoint'])
          conn.create_table?(:bot_sessions) do
            String :channel_id
            String :user
            String :params, text: true
            String :files, text: true
            String :cmd
            String :requested_param
            String :last_message, text: true
          end
        end

        def run_dynamoid_migrations(config)
          repository = Kybus::Storage::Datasource::DynamoidRepository.from_config(
            'name' => 'dynamoid',
            'dynamoid_config' => true,
            'access_key' => config['access_key'],
            'secret_key' => config['secret_key'],
            'region' => config['region'],
            'endpoint' => config['endpoint'],
            'namespace' => config['namespace'],
            'table' => 'bot_sessions',
            'primary_key' => 'channel_id',
            'fields' => Base::DYNAMOID_FIELDS,
            'read_capacity' => config['read_capacity'] || 1,
            'write_capacity' => config['write_capacity'] || 1
          )

          # Ensure the table is created
          unless Dynamoid.adapter.list_tables.include?('bot_sessions')
            repository.model_class.create_table(sync: true)
          end
        end
      end
    end
  end
end
