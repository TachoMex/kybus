# frozen_string_literal: true

require 'kybus/logger'
module Kybus
  module Server
    # Implements monitoring. This will add logs.
    # Currently it only support CuteLogger format, but it will be deprecated
    # in order to support a new log (actually kind of the same format).
    class Logger
      include Kybus::Logger
      def access_data(response)
        {
          path: response.path,
          ip: response.ip,
          verb: response.verb,
          processing_time:
            (Time.now - response.params[:__init_time]).to_f * 1000
        }
      end

      def access(response)
        log_info('Requesting resource', access_data(response))
      end

      def success(response)
        log_info('Success request', access_data(response))
      end

      def fail(response)
        log_info('Fail Response',
                 access_data(response)
                  .merge(message: response.exception.message))
      end

      def error(response)
        log_warn('Error dectected on response', access_data(response).merge(
                                                  error: response.exception
                                                ))
      end

      def fatal(response)
        log_error('Unexpected error on response',
                  access_data(response).merge(
                    error: response.exception,
                    data: response.params,
                    trace: response.exception.backtrace
                  ))
      end
    end
  end
end
