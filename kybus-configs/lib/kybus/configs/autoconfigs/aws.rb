# frozen_string_literal: true

module Kybus
  module Configuration
    module Autoconfigs
      class Aws < ServiceManager
        def self.from_config(config)
          aws = new(config, 'aws/')
          aws.configure!
          aws.all_services
        end

        register_plugin('sqs')
        register_plugin('s3')
      end

      register('aws', Aws)
    end
  end
end
