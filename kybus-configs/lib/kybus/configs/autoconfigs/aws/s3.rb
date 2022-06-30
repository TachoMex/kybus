# frozen_string_literal: true

module Kybus
  module Configuration
    module Autoconfigs
      class Aws
        class S3
          include Kybus::Configuration::Utils
          def self.from_config(config)
            require 'aws-sdk-s3'
            new(config)
          end

          def initialize(config)
            @config = config
            @client = ::Aws::S3::Client.new(
              symbolize(config).except(:bucket, :test_connection)
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
