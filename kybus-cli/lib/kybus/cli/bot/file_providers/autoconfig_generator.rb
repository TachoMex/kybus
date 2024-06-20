module Kybus
  class CLI < Thor
    class Bot < Thor
      module Config
        class AutoconfigGenerator < FileProvider

          autoregister!

          def saving_path
            'config/autoconfig.yaml'
          end

          def make_contents
            <<~YAML
              autoconfig:
                env_prefix: #{bot_name_constantize}
                default_files:
                  - ./config/config.default.yaml
                files:
                  - ./config/config.yaml
            YAML
          end
        end
      end
    end
  end
end
