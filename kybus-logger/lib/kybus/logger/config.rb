# frozen_string_literal: true

require 'logger'
require_relative 'format'

module Kybus
  module Logger
    class Config
      include Kybus::DRY::ResourceInjector
      include Kybus::Logger::Format
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

      def init_log_file
        log_output = if @original_config['stdout']
                       $stdout
                     else
                       @original_config['file'] || 'application.log'
                     end
        register('file', log_output)
        register('rotate_days', @original_config['rotate_days'] || 7)
        register('rotate_size', @original_config['rotate_size'] || (100 * (1024**2))) # 100Mb
      end

      def initialize(config)
        @original_config = config
        init_log_file
        register('date_format', config['date_format'] || '%Y-%m-%d %H:%M:%S')
        register('severity', config['severity'] || 'info')
        register('log_format', config['log_format'] || "%time,%sev,%pid,%tid,%mod,%json\n")
        register('blacklist', config['blacklist'] || %w[pass password])
        register('logger', logger)
      end

      def logger
        @logger ||= begin
          log_output = resource('file')
          if log_output == $stdout
            logger = ::Logger.new(log_output)
          else
            logger = ::Logger.new(
              log_output,
              resource('rotate_days'),
              resource('rotate_size')
            )
          end
          $stdout.sync = true if @original_config['stdout']
          logger.sev_threshold = SEVERITIES[resource('severity')]
          logger.datetime_format = resource('date_format')
          logger.formatter = format_builder(resource('log_format'))
          logger
        end
      end

      def merge_params(msg, data, debug)
        blacklist = resource('blacklist') + ['debug']
        params = {}
        data.each { |k, v| params[k] = v unless blacklist.include?(k.to_s) }
        params[:debug] = debug if resource('severity') == 'debug'
        [msg, params]
      end
    end
  end
end
