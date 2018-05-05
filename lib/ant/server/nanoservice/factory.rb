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
          model = @model.new(data, repository)
          model.create
          model
        end

        def get(id, source = resource(:default))
          repository = resource(source)
          model = repository.get(id)
          @model.new(model, repository)
        end
      end
    end
  end
end
