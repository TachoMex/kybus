require_relative 'repository'

module Ant
  module Server
    module Nanoservice
      module Datasource
        class Sequel < Repository
          def initialize(sequel_object, id, id_generator)
            @sequel = sequel_object
            super(id, id_generator)
          end

          def get(id)
            result = @sequel.where(@id => id).first
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
end
