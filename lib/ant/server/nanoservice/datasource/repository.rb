require_relative 'exceptions'

module Ant
  module Server
    module Nanoservice
      module Datasource
        class Repository
          include Exceptions
          def initialize(id, id_generator)
            @id = id
            @id_generator = id_generator
          end

          def create_initial_object(id)
            object = { @id => @id_generator.call(id, @id) }
            object.merge!(id) if id.is_a?(Hash)
            object
          end

          def create(id = nil)
            data = create_initial_object(id)
            raise(ObjectAlreadyExists, data[@id]) if exist?(data[@id])
            create_(data)
          end

          def exist?(id)
            get(id)
            true
          rescue ObjectNotFound
            false
          end
        end
      end
    end
  end
end
