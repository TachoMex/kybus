# frozen_string_literal: true

module Ant
  module DRY
    # Use this for running tasks that will be looping by only sending a lambda
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

            log_error('Unexpected error', error: ex)
          end
          sleep(@wait_time)
        end
      end

      def run
        if @attach
          task
        else
          @thread = Thread.new { task }
        end
      end

      def await
        @thread&.join
      end
    end
  end
end
