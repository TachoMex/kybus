module Kybus
  class CLI < Thor
    class Bot < Thor
      module Config
        class DBGenerator < FileProvider
          autoregister!

          def saving_path
            'config_loaders/db.rb'
          end

          def make_contents
            case @config[:db_adapter]
            when 'sequel'
              <<-RUBY
# frozen_string_literal: true

require 'sequel'

DB = Sequel.connect(APP_CONF['database'])

def run_migrations!
  require 'kybus/bot/migrator'
  require 'sequel/core'
  Kybus::Bot::Migrator.run_migrations!(APP_CONF['bots']['main']['state_repository'])
  Sequel.extension :migration
  Sequel::Migrator.run(DB, 'models/migrations')
end
              RUBY
            when 'activerecord'
              <<-RUBY
# frozen_string_literal: true

require 'active_record'

ActiveRecord::Base.establish_connection(APP_CONF['database'])
              RUBY
            when 'dynamoid'
              <<-RUBY
              RUBY
            end
          end
        end
      end
    end
  end
end
