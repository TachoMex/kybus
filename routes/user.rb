class UserRoutes < Grape::API
  Services.schema.mount_grape_helpers(UserRoutes, 'users')

  namespace :users do
    post do
      factory.create(params)
    end

    route_param :user_id do
      get do
        factory.get(params['user_id'])
      end
    end
  end
end
