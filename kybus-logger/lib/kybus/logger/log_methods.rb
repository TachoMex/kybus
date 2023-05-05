# frozen_string_literal: true

module Kybus
  module Logger
    module LogMethods
      extend Kybus::DRY::ResourceInjector

      def self.global_config
        LogMethods.resource(:global_config)
      end

      def self.global_config=(config)
        LogMethods.register(:global_config, config)
      end

      %i[debug info warn error fatal].each do |level|
        define_method("log_#{level}".to_s) do |msg, data = nil|
          debug = {}
          case data
          when Hash
            debug = data.delete(:debug)
          when NilClass
            data = {}
          when String
            data = [data]
          when Exception
            data = { message: data.message, class: data.class, stack: data.backtrace }
          end
          log_raw(level, msg, data, debug)
        end
      end

      def log_metric(metric:, amount:, group: nil, time: nil)
        log_info('Metric', metric:, value: amount,
                           group:, time:)
      end

      def log_alert(description:, group:, alert_severity:, notify_group:)
        log_fatal('Alert Triggered',
                  description:,
                  group:,
                  severity: alert_severity,
                  notify_group:)
      end

      def log_raw(severity, msg, data, debug = {})
        sev = Config::SEVERITIES[severity.to_s]
        meta = config.merge_params(msg, data, debug)
        config.logger.add(sev, meta, self.class.name)
      end

      def config
        self.class.respond_to?(:resource) ? self.class.resource(:log_config) : LogMethods.global_config
      rescue StandardError => _e
        # :nocov:
        Kybus::Logger::LogMethods.global_config
        # :nocov:
      end

      LogMethods.global_config = Config.from_config({})
    end
  end
end
