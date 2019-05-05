# frozen_string_literal: true

require_relative 'repository'

module Ant
  module Storage
    module Datasource
      # Repository that fetch and store objects using a sequel connection
      # as resource.
      class Sequel < Repository
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
          @sequel
        end
      end
    end
  end
end
