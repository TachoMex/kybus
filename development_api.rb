require 'grape'
require 'sequel'

require_relative 'lib/ant'
require_relative 'lib/ant/nanoservice'
require_relative 'lib/ant/server/grape'
require_relative 'lib/ant/http_exceptions'
require './lib/ant/configs'


require_relative 'helpers/factory_helpers'
require_relative 'api/lib/services'

require_relative 'routes/basic_auth_routes'
require_relative 'routes/basic_routes'
require_relative 'routes/nanoservice'
require_relative 'routes/user'

class DevelopmentAPI < Grape::API
  include Ant::Server::GrapeDecorator

  version('v1', using: :header, vendor: :cut)
  prefix(:api)
  format(:json)

  helpers FactoryHelpers
  helpers BasicAuthRoutes::AuthHelper

  mount Nanoservice
  mount BasicRoutes
  mount BasicAuthRoutes
  mount UserRoutes
end
