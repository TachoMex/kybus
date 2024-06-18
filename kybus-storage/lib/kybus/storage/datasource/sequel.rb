# frozen_string_literal: true

require_relative 'repository'

module Kybus
  module Storage
    module Datasource
      # Repository that fetch and store objects using a sequel connection
      # as resource.
      class Sequel < Repository
        def self.from_config(conf)
          require 'sequel'
          conf['table'] ||= conf['schema_name']
          conn = ::Sequel.connect(conf['endpoint'], conf)[conf['table'].to_sym]
          if conf['schema'].nil?
            # TODO: decouple use of classes
            new(conn, conf['primary_key'].to_sym,
                IDGenerators[:id])
          else
            # TODO: This line is very high coupled to kybus-nanoservice
            new(conn, conf['schema']::PRIMARY_KEY, IDGenerators[:id])
          end
        end

        def initialize(sequel_object, id, id_generator)
          @sequel = sequel_object
          super(id, id_generator)
        end

        def get(id)
          result = @sequel.where(@id.to_sym => id).first
          raise(ObjectNotFound, id) if result.nil?

          result
        end

        def create_(data)
          id = @sequel.insert(data)
          data[@id] ||= id
          data
        end

        def store(data)
          data2 = data.dup
          data2.delete(@id)
          @sequel.where(@id => data[@id]).update(data2)
        end

        def connection
          @sequel.db
        end
      end
    end
  end
end
