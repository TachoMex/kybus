module Ant
  module Server
    module Nanoservice
      module Datasource
        module Exceptions
          class ObjectAlreadyExists < Ant::Exceptions::AntFail
            attr_reader :id
            def initialize(id)
              @id = id
              super("Object #{id} already exists", nil, id: id)
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
