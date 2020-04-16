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
          @logger = Object.new
          @logger.extend Ant::Logger
        end

        def raw
          @logger
        end
      end

      register('logger', Logger)
    end
  end
end
