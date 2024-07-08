# frozen_string_literal: true

module Kybus
  module AWS
    class Resource
      attr_reader :region

      def initialize(config)
        @config = config
        @region = @config['region'] || 'us-east-1'
      end

      def account_id
        @config['account_id']
      end

      def with_retries(exception, max_retries = 5)
        retry_count = 0
        begin
          yield
        rescue exception
          retry_count += 1
          unless retry_count <= max_retries
            raise "Failed to apply #{self.class} after #{max_retries} attempts due to ongoing updates."
          end

          sleep_time = 2**retry_count
          puts "Update in progress, retrying in #{sleep_time} seconds..."
          sleep(sleep_time)
          retry
        end
      end
    end
  end
end
