require 'securerandom'

module Kybus
  class CLI < Thor
    class Bot < Thor
      module Config
        class DeploymentFileProvide < FileProvider
          autoregister!
          def saving_path
            './kybusbot.yaml'
          end

          def skip_file?
            !@config[:with_deployment_file]
          end

          def make_contents
            <<~YAML
              name: #{bot_name_snake_case}
              cloud_provider: #{@config[:cloud_provider]}
              dynamo:
                capacity: #{@config[:dynamo_capacity]}
                table_name: #{@config[:dynamo_table]}
              chat_provider: #{@config[:bot_provider]}
              bot_token: #{@config[:bot_token]}
              secret_token: #{generate_secret_token}
            YAML
          end

          def generate_secret_token
            SecureRandom.alphanumeric(64)
          end
        end
      end
    end
  end
end
