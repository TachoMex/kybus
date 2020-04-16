# frozen_string_literal: true

module Ant
  module Configuration
    module Autoconfigs
      class Aws
        class S3
          include Ant::Configuration::Utils
          def self.from_config(config)
            require 'aws-sdk-s3'
            new(config)
          end

          def initialize(config)
            @config = config
            @client = ::Aws::S3::Client.new(
              symbolize(config).reject do |k, _|
                %i[bucket test_connection].include?(k)
              end
            )
            @connection = ::Aws::S3::Bucket.new(
              name: config['bucket'],
              client: @client
            )
          end

          def raw
            @connection
          end
        end
      end
      register('s3', Aws::S3)
    end
  end
end
