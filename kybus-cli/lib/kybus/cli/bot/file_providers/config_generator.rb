# frozen_string_literal: true

module Kybus
  class CLI < Thor
    class Bot < Thor
      module Config
        class ConfigGenerator < FileProvider
          autoregister!

          DB_CONFIGS = {
            'sequel' => <<-SEQUEL.chomp,
              name: sequel
              endpoint: 'sqlite://${bot_name_snake_case}_botmeta.db'
            SEQUEL
            'dynamoid' => <<-DYNAMOID.chomp
              name: dynamoid
              dynamoid_config: true
              region:  'us-east-1'
              namespace: '${bot_name_snake_case}'
              read_capacity: 3
              write_capacity: 3
            DYNAMOID
          }.freeze

          def saving_path
            'config/config.yaml'
          end

          def make_contents
            <<~YAML + db_config.gsub('${bot_name_snake_case}', bot_name_snake_case)
              bots:
                main:
                  provider:
                    name: #{@config[:bot_provider]}
                    token: #{@config[:bot_token]}
                    mode: #{@config[:with_deployment_file] && @config[:cloud_provider] == 'aws' ? 'webhook_lambda' : 'polling'}
                    debug: true
                  state_repository:
            YAML
          end

          private

          def db_config
            DB_CONFIGS[@config[:db_adapter]] || ''
          end
        end
      end
    end
  end
end
