# frozen_string_literal: true

module Kybus
  class CLI < Thor
    class Bot < Thor
      module Config
        class ConfigDefaultGenerator < FileProvider
          autoregister!
          def saving_path
            'config/config.default.yaml'
          end

          def keep_files
            ['models/migrations/.keep']
          end

          def make_contents
            content = <<~YAML
              logger:
                stdout: yes
                severity: debug
              bots:
                main:
                  pool_size: 1
                  inline_args: true
                  provider:#{' '}
                    name: REPLACE_ME
                    token: REPLACE_ME
                    debug: true
                  state_repository:
            YAML

            if @config[:db_adapter] == 'sequel'
              content << <<~SEQUEL
                        name: sequel
                        endpoint: 'sqlite://#{bot_name_snake_case}_botmeta.db'
                database: 'sqlite://#{bot_name_snake_case}.db'
              SEQUEL
            elsif @config[:db_adapter] == 'dynamoid'
              content << <<-DYNAMOID
        name: json
        storage: ./storage
              DYNAMOID
            end
          end
        end
      end
    end
  end
end
