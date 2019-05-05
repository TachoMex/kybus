# frozen_string_literal: true

module Ant
  module DRY
    # Use this for running tasks that will be looping by only sending a lambda
    # TODO: Improve this class.
    # - Add a maechanism for killing the process
    # - Add a function to test how many threads are alive
    # - Make it testable
    # - Add unit tests
    class Daemon
      def initialize(wait_time, attach, retry_on_failure = false)
        @proc = -> { yield }
        @wait_time = wait_time
        @attach = attach
        @retry_on_failure = retry_on_failure
        @finish = false
      end

      def task
        log_info 'starting daemon'
        loop do
          begin
            @proc.call
          rescue StandardError => ex
            raise unless @retry_on_failure

            # :nocov: #
            log_error('Unexpected error', error: ex)
            # :nocov: #
          end
          sleep(@wait_time)
        end
      end

      def run
        if @attach
          task
        else
          # :nocov: #
          @thread = Thread.new { task }
          # :nocov: #
        end
      end

      # :nocov: #
      def await
        @thread&.join
      end
      # :nocov: #
    end
  end
end
