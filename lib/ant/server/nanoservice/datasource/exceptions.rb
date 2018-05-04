module Ant
  module Server
    module Nanoservice
      module Datasource
        module Exceptions
          class ObjectNotFound < StandardError
            attr_reader :id
            def initialize(id)
              @id = id
              super("Object #{id} does not exist")
            end
          end
        end
      end
    end
  end
end
