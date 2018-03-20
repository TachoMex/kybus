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
end
