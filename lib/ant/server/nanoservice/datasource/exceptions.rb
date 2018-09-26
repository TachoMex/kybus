module Ant
  module Server
    module Nanoservice
      module Datasource
        module Exceptions
          class ObjectAlreadyExists < Ant::Exceptions::AntFail
            attr_reader :id
            def initialize(id, object)
              @id = id
              super("Object #{id} already exists", nil, object)
            end
          end

          class ValidationErrors < Ant::Exceptions::AntFail
            def initialize(data)
              @id = id
              super('Error while validating object', 'ValidationErrors', data)
            end
          end

          class ObjectNotFound < Ant::Exceptions::AntFail
            attr_reader :id
            def initialize(id)
              @id = id
              super("Object #{id} does not exist", nil, id: id)
            end
          end
        end
      end
    end
  end
end
