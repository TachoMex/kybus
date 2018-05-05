require 'cute_logger'
module Ant
  module Server
    class CuteLogger
      def access_data(response)
        {
          path: response.path,
          ip: response.ip,
          verb: response.verb
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
                    data: response.params
                  ))
      end
    end
  end
end
