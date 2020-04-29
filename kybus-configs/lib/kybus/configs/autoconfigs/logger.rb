# frozen_string_literal: true

module Kybus
  module Configuration
    module Autoconfigs
      class Logger
        def self.from_config(config)
          require 'kybus/logger'
          new(config)
        end

        def initialize(config)
          @config = config
          Kybus::Logger::LogMethods.global_config = Kybus::Logger::Config.new(config)
          @logger = Object.new
          @logger.extend Kybus::Logger
        end

        def raw
          @logger
        end
      end

      register('logger', Logger)
    end
  end
end
