# frozen_string_literal: true

require 'sequel'
require 'sequel/extensions/migration'
module Kybus
  module Bot
    module Migrator
      class << self
        def run_migrations!(conn)
          conn.create_table?(:bot_sessions) do
            String :channel_id
            String :user
            String :params, text: true
            String :files, text: true
            String :cmd
            String :requested_param
          end
        end
      end
    end
  end
end
