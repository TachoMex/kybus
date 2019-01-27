module Services
  class << self
    def configs
      @configs ||= begin
        configs = Ant::Configuration::ConfigurationManager.new(
          default_files: './config/nanoservice_default.yaml'
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
