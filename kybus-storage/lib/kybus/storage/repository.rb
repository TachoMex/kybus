# frozen_string_literal: true

require_relative 'datasource/json_repository'
require_relative 'datasource/sequel'
require_relative 'factory'

module Kybus
  module Storage
    # Singleton storing all the implemented repositories. It also allows to
    # register new repositories for extension.
    module Repository
      extend Kybus::DRY::ResourceInjector
      include Kybus::Storage::Datasource

      register(:repositories, :json, JSONRepository)
      register(:repositories, 'json', JSONRepository)
      register(:repositories, :sequel, Sequel)
      register(:repositories, 'sequel', Sequel)

      def self.from_config(schema, sets, default)
        conf = default.merge(sets || {}).merge('schema' => schema)
        resource(:repositories, conf['name']).from_config(conf)
      end
    end
  end
end
