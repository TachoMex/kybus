require_relative 'metatypes'
require_relative 'datasource/json_repository'
require_relative 'datasource/id_generators'

module Ant
  module Server
    module Nanoservice
      class Schema
        attr_reader :schema

        def initialize(schema)
          @schema = schema['models'].each_with_object({}) do |(name, columns), obj|
            obj[name] = MetaTypes.build(name, columns)
          end
        end
      end
    end
  end
end
