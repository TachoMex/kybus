# frozen_string_literal: true

# This API provides routes to test JSend formats.
class BasicRoutes < Grape::API
  include Ant::Logger

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

  get :success do
    raise(Ant::Exceptions::AntSuccess, 'U scare bro?')
  end

  get :slow do
    sleep(2)
    'Sorry for the delay!'
  end
end
