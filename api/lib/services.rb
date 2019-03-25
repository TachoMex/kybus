# frozen_string_literal: true

# Services module provides configurations and a singleton context for grape API.
# It is not the best practice but since Grape uses singleton this is required
# to allow an smooth integration with it.
# Before adding something here you should evaluate adding the ServiceManager.
module Services
  class << self
    def configs
      @configs ||= begin
        configs = Ant::Configuration::ConfigurationManager.new(
          default_files: [
            './config/nanoservice_default.yaml',
            './config/bot_default.yaml'
          ]
        )
        configs.load_configs!
        configs
      end
    end

    def schema
      @schema ||= Ant::Server::Nanoservice::Schema.new(configs['schema'])
    end
  end
end
