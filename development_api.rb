require './lib/ant'
require 'grape'
require './lib/ant/server/grape'

class DevelopmentAPI < Grape::API
  include Ant::Server::GrapeDecorator

  version('v1', using: :header, vendor: :cut)
  prefix(:api)
  format(:json)

  get :status do
    log_info('Requesting status for server')
    {
      status: 'server running',
      time: Time.now,
      hello: 'world'
    }
  end

  get :fatal do
    log_info('trying to do magic')
    raise('I do not know what happened')
  end

  get :fail do
    raise(Ant::Exceptions::AntFail, 'Wrong Value')
  end

  get :error do
    raise(Ant::Exceptions::AntError, 'The system crashed')
  end

  class AuthenticationError < Ant::Exceptions::AntFail
    def initialize
      super('Unauthorized. Please provide proper keys')
    end

    def http_code
      401
    end
  end

  module AuthHelper
    def current_user!
      token = env['HTTP_AUTHORIZATION']
      raise(AuthenticationError) unless token && /^Basic .*/.match(token)
      data = token.tr('Basic ', '')
      user, pass = Base64.decode64(data).split(':')
      raise(AuthenticationError) unless user == 'test' && pass == 'secret'
      user
    end
  end

  helpers AuthHelper

  namespace :secret do
    get do
      user = current_user!
      { money: 1000, user: user }
    end
  end
end
