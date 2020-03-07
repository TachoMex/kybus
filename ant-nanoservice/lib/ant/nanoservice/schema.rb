# frozen_string_literal: true

require 'ant/storage'

require_relative 'metatypes'

module Ant
  module Nanoservice
    # Takes a configuration and creates the metaclasess, repositories and
    # factory from them.
    # this can be attached to Grape API as helpers and provide a connection
    # to the data layer.
    class Schema
      attr_reader :schema, :repositories

      def initialize(schema)
        build_schemas(schema['models'])
        build_repositories(schema['models'], schema['repositories'])
      end

      private

      def build_schemas(models)
        @schema_configs = {}
        @schema = models.each_with_object({}) do |(name, configs), obj|
          columns = configs['fields']
          @schema_configs[name] = configs
          configs['configs']['schema_name'] = name
          obj[name] = MetaTypes.build(name, columns, configs)
        end
      end

      def build_repositories(models, repository_conf)
        @repositories = models.each_with_object({}) do |(name, _), obj|
          obj[name] = Ant::Storage::Repository
                      .from_config(@schema[name],
                                   @schema_configs[name]['configs'],
                                   repository_conf['default'])
        end
      end

      public

      def mount_grape_helpers(api, schema_name)
        model = schema[schema_name]
        repo = repositories[schema_name]
        api.helpers do
          define_method('factory') do
            @factory ||= begin
              factory = Ant::Storage::Factory.new(model)
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
