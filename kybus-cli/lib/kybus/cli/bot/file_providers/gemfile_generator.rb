module Kybus
  class CLI < Thor
    class Bot < Thor
      module Config
        class GemfileGenerator < FileProvider
          autoregister!
          def saving_path
            './Gemfile'
          end

          private

          def make_contents
            <<~GEMFILE
              source 'https://rubygems.org'

              gem 'kybus-bot'
              gem '#{@config[:db_adapter]}'
              gem 'minitest'
              gem 'kybus-storage'
              gem 'kybus-logger'
              gem 'kybus-configs'
              gem 'rake'
              group :telegram do
                gem 'telegram-bot-ruby'
              end
              group :discord do 
                gem 'discordrb'
              end
              group :development do 
                gem 'sqlite3'
              end
            GEMFILE
          end
        end
      end
    end
  end
end
