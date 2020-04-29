# frozen_string_literal: true

module Kybus
  module Configuration
    module Autoconfigs
      class Aws
        class Sqs
          include Kybus::Configuration::Utils
          def self.from_config(config)
            require 'aws-sdk-sqs'
            new(config)
          end

          def initialize(config)
            @config = config
            @client = ::Aws::SQS::Client.new(
              symbolize(config).reject do |k, _|
                %i[queue test_connection].include? k
              end
            )
            queue = @client.get_queue_url(queue_name: @config['queue'])
            @connection = ::Aws::SQS::Queue.new(
              url: queue[:queue_url],
              client: @client
            )
          end

          def raw
            @connection
          end
        end
      end
      register('sqs', Aws::Sqs)
    end
  end
end
