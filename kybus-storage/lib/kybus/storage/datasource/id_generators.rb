# frozen_string_literal: true

module Kybus
  module Storage
    module Datasource
      # This class was meant to handle the complexity of extracting the
      # primary key from an object that belongs to a model. This might get
      # deprecated or suffer a huge refactor.
      class IDGenerators
        extend DRY::ResourceInjector
        def self.[](key)
          resource(:generators, key)
        end

        def self.normalize_id(object, key)
          object.is_a?(Hash) || object.nil? ? object[key] : object
        end

        id_generator = ->(id, key) { normalize_id(id, key) }
        register(:generators, :id, id_generator)
      end
    end
  end
end
