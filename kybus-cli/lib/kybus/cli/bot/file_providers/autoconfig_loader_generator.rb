module Kybus
  class CLI < Thor
    class Bot < Thor
      module Config
        class AutoconfigLoaderGenerator < FileProvider
          autoregister!

          def saving_path
            'config_loaders/autoconfig.rb'
          end

          private

          def make_contents
            <<-RUBY
require 'kybus/bot'
require 'kybus/configs'


Dir[File.join(__dir__, './models', '*.rb')].each { |file| require file }

require_relative '../bot'

CONF_MANAGER = Kybus::Configuration.auto_load!
APP_CONF = CONF_MANAGER.configs
require_relative 'db'

require_relative "bot_builder"
            RUBY
          end
        end
      end
    end
  end
end
