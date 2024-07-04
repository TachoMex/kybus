# frozen_string_literal: true

module Kybus
  class CLI < Thor
    class Bot < Thor
      module Config
        class ConfigDefaultGenerator < FileProvider
          autoregister!

          DB_CONFIGS = {
            'sequel' => <<~SEQUEL.chomp,
              name: sequel
              endpoint: 'sqlite://${bot_name_snake_case}_botmeta.db'
              database: 'sqlite://${bot_name_snake_case}.db'
            SEQUEL
            'dynamoid' => <<~DYNAMOID.chomp
              name: json
              storage: ./storage
            DYNAMOID
          }.freeze

          def saving_path
            'config/config.default.yaml'
          end

          def keep_files
            ['models/migrations/.keep']
          end

          def make_contents
            <<~YAML + db_config.gsub('${bot_name_snake_case}', bot_name_snake_case)
              logger:
                stdout: yes
                severity: debug
              bots:
                main:
                  pool_size: 1
                  inline_args: true
                  provider:
                    name: REPLACE_ME
                    token: REPLACE_ME
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
