module Ant
  module Server
    module Nanoservice
      class Factory
        include Ant::DRY::ResourceInjector

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
end
