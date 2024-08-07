# frozen_string_literal: true

require 'kybus/exceptions'
module Kybus
  module Storage
    module Exceptions
      # Exception used when there is an object trying to be created but it
      # already exists.
      class ObjectAlreadyExists < Kybus::Exceptions::KybusFail
        attr_reader :id

        def initialize(id, object)
          @id = id
          super("Object #{id} already exists", nil, object)
        end
      end

      # Exception used when a value on a model violates the restrictions
      # from the validators.
      class ValidationErrors < Kybus::Exceptions::KybusFail
        def initialize(data)
          super('Error while validating object', 'ValidationErrors', data)
        end
      end

      # Exception used when it is requested an object that can not be found.
      class ObjectNotFound < Kybus::Exceptions::KybusFail
        attr_reader :id

        def initialize(id)
          @id = id
          super("Object #{id} does not exist", nil, id:)
        end
      end
    end
  end
end
