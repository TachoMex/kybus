require 'cute_logger'
module Ant
  module Server
    class CuteLogger
      def access(response)
        log_info('Requesting resource',
                 path: response.path,
                 ip: response.ip,
                 verb: response.verb)
      end

      def success(response)
        log_info('Success request',
                 path: response.path,
                 verb: response.verb)
      end

      def fail(response)
        log_info('Fail Response',
                 path: response.path,
                 verb: response.verb)
      end

      def error(response)
        log_warn('Error dectected on response',
                 path: response.path,
                 verb: response.verb,
                 error: response.exception)
      end

      def fatal(response)
        log_error('Unexpected error on response',
                  path: response.path,
                  verb: response.verb,
                  error: response.exception,
                  data: response.params)
      end
    end
  end
end
