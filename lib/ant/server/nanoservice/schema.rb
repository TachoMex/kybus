require_relative 'metatypes'
require_relative 'datasource/json_repository'
require_relative 'datasource/id_generators'
require_relative '../repository'

module Ant
  module Server
    module Nanoservice
      class Schema
        attr_reader :schema, :repositories

        def initialize(schema)
          @schema = schema['models'].each_with_object({}) do |(name, columns), obj|
            obj[name] = MetaTypes.build(name, columns)
          end

          repository_conf = schema['repositories']

          @repositories = schema['models'].each_with_object({}) do |(name, _col), obj|
            obj[name] = Ant::Server::Nanoservice::Repository.from_config(@schema[name], repository_conf[name], repository_conf['default'])
          end
        end

        def mount_grape_helpers(api, schema_name)
          model = schema[schema_name]
          repo = repositories[schema_name]
          api.helpers do
            define_method('factory') do
              @factory ||= begin
                factory = Ant::Server::Nanoservice::Factory.new(model)
                factory.register(:default, :primary)
                factory.register(:primary, repo)
                factory
              end
            end
          end
        end
      end
    end
  end
end
