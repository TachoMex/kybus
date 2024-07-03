# frozen_string_literal: true

module Kybus
  class CLI < Thor
    class Bot < Thor
      module Config
        class BotBuilderGenerator < FileProvider
          autoregister!

          def saving_path
            'config_loaders/bot_builder.rb'
          end

          def make_contents
            <<~RUBY
              # frozen_string_literal: true

              BOT = #{bot_name_class}.new(APP_CONF['bots']['main'])
            RUBY
          end
        end
      end
    end
  end
end
