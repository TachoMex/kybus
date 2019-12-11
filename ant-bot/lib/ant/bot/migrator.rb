require 'sequel'
require 'sequel/extensions/migration'
module Ant
  module Bot
    module Migrator
      class << self
        def run_migrations!(conn)
          conn.create_table?(:bot_sessions) do
            String :channel_id, primary: true
            String :params, text: true
            String :cmd
            String :requested_param
          end
        end
      end
    end
  end
end
