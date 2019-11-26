# frozen_string_literal: true

require 'logger'

require_relative 'format'

module Ant
  module Logger
    class Config
      include Ant::DRY::ResourceInjector
      include Ant::Logger::Format
      SEVERITIES = {
        'debug' => ::Logger::DEBUG,
        'info' => ::Logger::INFO,
        'warn' => ::Logger::WARN,
        'error' => ::Logger::ERROR,
        'fatal' => ::Logger::FATAL
      }.freeze

      def self.from_config(config)
        new(config)
      end

      def initialize(config)
        @original_config = config
        register('file', config['stdout'] ? STDOUT : config['file'] || 'application.log')
        register('rotate_days', config['rotate_days'] || 7)
        register('rotate_size', config['rotate_size'] || 100 * 1024**2) # 100Mb
        register('date_format', config['date_format'] || '%Y-%m-%d %H:%M:%S')
        register('severity', config['severity'] || 'info')
        register('log_format', config['log_format'] ||
                 "%time,%sev,%pid,%tid,%mod,%json\n")
        register('blacklist', config['blacklist'] || %w[pass password])
        register('logger', logger)
      end

      def logger
        @logger ||= begin
          logger = ::Logger.new(
            resource('file'),
            resource('rotate_days'),
            resource('rotate_size')
          )
          logger.sev_threshold = SEVERITIES[resource('severity')]
          logger.datetime_format = resource('date_format')
          logger.formatter = format_builder(resource('log_format'))
          logger
        end
      end

      def merge_params(msg, data, debug, severity)
        blacklist = resource('blacklist') + ['debug']
        params = {}
        data.each { |k, v| params[k] = v unless blacklist.include?(k.to_s) }
        params[:debug] = debug if resource('severity') == 'debug'
        [msg, params]
      end
    end
  end
end
