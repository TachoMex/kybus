# frozen_string_literal: true

# API for tuples. Provides endpoints for testing repository and factory
# components
class Nanoservice < Grape::API
  namespace :nanoservice do
    route_param :repository do
      namespace :tuples do
        route_param :id do
          get do
            factory.get(params[:id], params[:repository])
          end

          post do
            data = { key: params[:id], value: params[:value] }
            factory.create(data, params[:repository])
          end
        end
      end
    end
  end
end
