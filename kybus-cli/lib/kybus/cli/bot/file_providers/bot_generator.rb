# frozen_string_literal: true

module Kybus
  class CLI < Thor
    class Bot < Thor
      class BotGenerator < FileProvider
        autoregister!
        def saving_path
          'bot.rb'
        end

        def make_contents
          <<~RUBY
            # frozen_string_literal: true

            class #{bot_name_class} < Kybus::Bot::Base
              def initialize(configs)
                super(configs)
                register_command('/hello') do
                  send_message('Hi human')
                end
              end
            end
          RUBY
        end
      end
    end
  end
end
