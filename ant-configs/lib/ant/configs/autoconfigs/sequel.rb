# frozen_string_literal: true

module Ant
  module Configs
    module Autoconfigs
      CONFIG_KEYS = {
        "adapter": {
          "desc": 'The adapter to use',
          "default": nil
        },
        "database": {
          "desc": 'The name of the database to which to connect',
          "default": nil
        },
        "extensions": {
          "desc": 'Extensions to load into this Database instance. Can be a symbol, array of symbols, or string with extensions separated by columns. These extensions are loaded after connections are made by the :preconnect option.',
          "default": nil
        },
        "cache_schema": {
          "desc": 'Whether schema should be cached for this database (true by default)',
          "default": nil
        },
        "default_string_column_size": {
          "desc": 'The default size for string columns (255 by default)',
          "default": nil
        },
        "host": {
          "desc": 'The hostname of the database server to which to connect',
          "default": nil
        },
        "keep_reference": {
          "desc": 'Whether to keep a reference to the database in Sequel::DATABASES (true by default)',
          "default": nil
        },
        "logger": {
          "desc": 'A specific SQL logger to log to',
          "default": nil
        },
        "loggers": {
          "desc": 'An array of SQL loggers to log to',
          "default": nil
        },
        "log_connection_info": {
          "desc": 'Whether to include connection information in log messages (false by default)',
          "default": nil
        },
        "log_warn_duration": {
          "desc": 'The amount of seconds after which the queries are logged at :warn level',
          "default": nil
        },
        "password": {
          "desc": 'The password for the user account',
          "default": nil
        },
        "preconnect": {
          "desc": 'Whether to automatically make the maximum number of connections when setting up the pool. Can be set to “concurrently” to connect in parallel.',
          "default": nil
        },
        "preconnect_extensions": {
          "desc": 'Similar to the :extensions option, but loads the extensions before the connections are made by the :preconnect option.',
          "default": nil
        },
        "quote_identifiers": {
          "desc": 'Whether to quote identifiers.',
          "default": nil
        },
        "servers": {
          "desc": 'A hash with symbol keys and hash or proc values, used with primary/replica and sharded database configurations',
          "default": nil
        },
        "sql_log_level": {
          "desc": 'The level at which to issue queries to the loggers (:info by default)',
          "default": nil
        },
        "test": {
          "desc": 'Whether to test that a valid database connection can be made (true by default)',
          "default": nil
        },
        "user": {
          "desc": 'The user account name to use logging in',
          "default": nil
        }
      }.freeze

      class Sequel
        def self.from_config(config)
          require 'sequel'
          new(config)
        end

        def initialize(config)
          @config = config
          @connection = ::Sequel.connect(config)
        end

        def sanity_check
          @connection.fetch('select 1 + 1;')
        end

        def raw
          @connection
        end

        def help
          CONFIG_KEYS
        end
      end
    end
  end
end
