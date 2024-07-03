# frozen_string_literal: true

module Kybus
  module CLI
    module Bot
      class DeployInitGenerator
        def initialize(name, options)
          @file_writer = Kybus::CLI::FileWriter.new(name)
          @options = options
        end

        def generate
          @file_writer.write('.kybusbot.yaml', config_yaml_content)
        end

        private

        def config_yaml_content
          <<~YAML
            bot_name: #{bot_name_snake_case}
            cloud_provider: #{@options[:cloud_provider] || 'aws'}
            dynamo:
              capacity: #{@options[:dynamo_capacity] || 'on_demand'}
              table_name: #{@options[:dynamo_table] || 'bot_sessions'}
            chat_provider: #{@options[:chat_provider] || 'telegram'}
            telegram:
              token: 'REPLACE_ME'
          YAML
        end
      end
    end
  end
end
