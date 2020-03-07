# frozen_string_literal: true

module Ant
  module Configuration
    module Autoconfigs
      class Logger
        def self.from_config(config)
          require 'ant/logger'
          new(config)
        end

        def initialize(config)
          @config = config
          Ant::Logger::LogMethods.global_config = Ant::Logger::Config.new(config)
        end

        def sanity_check
          true
        end

        def raw
          @logger
        end
      end

      register('logger', Logger)
    end
  end
end
