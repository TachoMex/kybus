# frozen_string_literal: true

module Kybus
  module Bot
    module Migrator
      class << self
        def run_migrations!(config)
          migrator = migrator_for(config['name'])
          migrator.run_migrations!(config)
        end

        private

        def migrator_for(name)
          case name
          when 'sequel'
            SequelMigrator
          when 'dynamoid'
            DynamoidMigrator
          else
            raise "Provider not supported #{name}"
          end
        end
      end

      class SequelMigrator
        class << self
          def run_migrations!(config)
            require 'sequel'
            require 'sequel/extensions/migration'

            conn = Sequel.connect(config['endpoint'])
            conn.create_table?(:bot_sessions) do
              String :channel_id
              String :user
              String :params, text: true
              String :metadata, text: true
              String :files, text: true
              String :cmd
              String :requested_param
              String :last_message, text: true
            end
          end
        end
      end

      class DynamoidMigrator
        class << self
          def run_migrations!(config)
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

            create_table_if_not_exists(repository)
          end

          private

          def create_table_if_not_exists(repository)
            return if Dynamoid.adapter.list_tables.include?('bot_sessions')

            repository.model_class.create_table(sync: true)
          end
        end
      end
    end
  end
end
