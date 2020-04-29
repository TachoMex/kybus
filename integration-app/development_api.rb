# frozen_string_literal: true

require 'grape'
require 'sequel'
require 'kybus/core'
require 'kybus/nanoservice'
require 'kybus/server'
require 'kybus/server/grape'
require 'kybus/configs'
require 'kybus/storage'

require_relative 'helpers/factory_helpers'
require_relative 'api/lib/services'

require_relative 'routes/basic_auth_routes'
require_relative 'routes/basic_routes'
require_relative 'routes/nanoservice'
require_relative 'routes/user'

# This API has growth a lot! The objective of this code is to make it easier
# to debug new features by implementing them inside the gem code and avoid
# having another repo for testing that would require this gem.
class DevelopmentAPI < Grape::API
  include Kybus::Server::GrapeDecorator

  version('v1', using: :header, vendor: :ant_server)
  prefix(:api)
  format(:json)

  helpers Kybus::Logger
  helpers FactoryHelpers
  helpers BasicAuthRoutes::AuthHelper

  mount Nanoservice
  mount BasicRoutes
  mount BasicAuthRoutes
  mount UserRoutes
end
