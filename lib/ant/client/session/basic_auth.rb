module Ant
  module Client
    module Session
      module BasicAuth
        def basic_auth(request, user:, password:)
          request[:basic_auth] ||= { username: user, password: password }
        end
      end
    end
  end
end
