module Ant
  module Server
    module Nanoservice
      module Repository
        extend Ant::DRY::ResourceInjector

        register(:repositories, :json, Ant::Server::Nanoservice::Datasource::JSONRepository)
        register(:repositories, 'json', Ant::Server::Nanoservice::Datasource::JSONRepository)

        def self.from_config(schema, sets, default)
          conf = default.merge(sets || {}).merge('schema' => schema)
          resource(:repositories, conf['name']).from_config(conf)
        end
      end
    end
  end
end
