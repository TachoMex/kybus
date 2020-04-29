# frozen_string_literal: true

# API for thesting the integration with BasicAuth
class BasicAuthRoutes < Grape::API
  # Provides helpers to take credentials from front end
  module AuthHelper
    def current_user!
      token = env['HTTP_AUTHORIZATION']
      unless token && /^Basic .*/.match(token)
        raise Kybus::Exceptions::HTTP::Unauthorized, 'Invalid token'
      end

      data = token.tr('Basic ', '')
      user, pass = Base64.decode64(data).split(':')
      unless user == 'test' && pass == 'secret'
        raise Kybus::Exceptions::HTTP::Unauthorized, 'Credentials are not correct'
      end

      status 202
      user
    end
  end

  namespace :secret do
    get do
      user = current_user!
      { money: 1000, user: user }
    end
  end
end
