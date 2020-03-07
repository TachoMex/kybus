# frozen_string_literal: true

module Ant
  module Logger
    module LogMethods
      extend Ant::DRY::ResourceInjector

      def self.global_config
        LogMethods.resource(:global_config)
      end

      def self.global_config=(config)
        LogMethods.register(:global_config, config)
      end

      def log_info(msg, data = {})
        log_raw(:info, msg, data, data[:debug])
      end

      def log_warn(msg, data = {})
        log_raw(:warn, msg, data, data[:debug])
      end

      def log_error(msg, data = {})
        log_raw(:error, msg, data, data[:debug])
      end

      def log_fatal(msg, data = {})
        log_raw(:fatal, msg, data, data[:debug])
      end

      def log_debug(msg, data = {})
        log_raw(:debug, msg, data)
      end

      def log_metric(metric:, amount:, group: nil, time: nil)
        log_info('Metric', metric: metric, value: amount,
                           group: group, time: time)
      end

      def log_alert(description:, tagging_group:, tagging_sev:, tagging_org:)
        log_fatal('Alert Triggered',
                  description: description,
                  group: tagging_group,
                  severity: tagging_sev,
                  response_team: tagging_org)
      end

      def log_raw(severity, msg, data, debug = {})
        sev = Config::SEVERITIES[severity.to_s]
        meta = config.merge_params(msg, data, debug, severity)
        config.logger.add(sev, meta, self.class.name)
      end

      def config
        self.class.respond_to?(:resource) ? self.class.resource(:log_config) : LogMethods.global_config
      rescue StandardError => _e
        global_config
      end

      LogMethods.global_config = Config.from_config({})
    end
  end
end
