# frozen_string_literal: true

require_relative 'exceptions'

module Ant
  module Storage
    module Datasource
      # Base class for repositories. The ID generator might get deprecated.
      # It provides the interface for storing objects inside any persistance
      # provider implemented.
      # TODO: Find a better strategy for primary key handling.
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
          existent = exist?(data[@id])
          raise(ObjectAlreadyExists.new(data[@id], existent)) if existent

          create_(data)
        end

        def exist?(id)
          get(id)
        rescue ObjectNotFound
          nil
        end
      end
    end
  end
end
