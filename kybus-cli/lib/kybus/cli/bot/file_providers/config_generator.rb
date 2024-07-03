# frozen_string_literal: true

module Kybus
  class CLI < Thor
    class Bot < Thor
      module Config
        class ConfigGenerator < FileProvider
          autoregister!
          def saving_path
            'config/config.yaml'
          end

          def make_contents
            content = <<~YAML
              bots:
                main:
                  provider:
                    name: #{@config[:bot_provider]}
                    token: #{@config[:bot_token]}
                    mode: #{@config[:with_deployment_file] && @config[:cloud_provider] == 'aws' ? 'webhook_lambda' : 'polling'}
                    debug: true
                  state_repository:
            YAML

            if @config[:db_adapter] == 'sequel'
              content << <<-SEQUEL
        name: sequel
        endpoint: 'sqlite://#{bot_name_snake_case}_botmeta.db'
              SEQUEL
            elsif @config[:db_adapter] == 'dynamoid'
              content << <<-DYNAMOID
        name: dynamoid
        dynamoid_config: true
        region:  'us-east-1'
        namespace: '#{bot_name_snake_case}'
        read_capacity: 3
        write_capacity: 3
              DYNAMOID
            end
          end
        end
      end
    end
  end
end
