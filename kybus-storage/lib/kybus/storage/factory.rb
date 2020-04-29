# frozen_string_literal: true

module Kybus
  module Storage
    # charge of sending objects into storage and fetching also from them.
    class Factory
      include Kybus::DRY::ResourceInjector

      def initialize(model)
        @model = model
      end

      def create(data, source = resource(:default))
        repository = resource(source)
        model = @model.new(data)
        model.repository = repository
        model.create
        model
      end

      def get(id, source = resource(:default))
        repository = resource(source)
        data = repository.get(id)
        model = @model.new(data)
        model.repository = repository
        model
      end
    end
  end
end
