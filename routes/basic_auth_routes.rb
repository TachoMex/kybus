class BasicAuthRoutes < Grape::API
  module AuthHelper
    def current_user!
      token = env['HTTP_AUTHORIZATION']
      unless token && /^Basic .*/.match(token)
        raise Exceptions::HTTP::Unauthorized, 'Invalid token'
      end

      data = token.tr('Basic ', '')
      user, pass = Base64.decode64(data).split(':')
      unless user == 'test' && pass == 'secret'
        raise Exceptions::HTTP::Unauthorized, 'Credentials are not correct'
      end

      raise Exceptions::HTTP::Accepted.new('Authorized User', user)
    end
  end

  namespace :secret do
    get do
      user = current_user!
      { money: 1000, user: user }
    end
  end
end
