# frozen_string_literal: true

module Ant
  module Configuration
    module Autoconfigs
      class Aws
        class Sqs
          include Ant::Configuration::Utils
          def self.from_config(config)
            require 'aws-sdk-sqs'
            new(config)
          end

          def initialize(config)
            @config = config
            @client = ::Aws::SQS::Client.new(
              symbolize(config).reject { |k, _| %i[queue test_connection].include? k }
            )
            @connection = ::Aws::SQS::Queue.new(
              url: @client.get_queue_url(queue_name: @config['queue'])[:queue_url],
              client: @client
            )
          end

          def sanity_check
            false
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
