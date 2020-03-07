# frozen_string_literal: true

module Ant
  module Client
    module Session
      # Implements basic auth functionality for http client
      module BasicAuth
        def basic_auth(request, user:, password:)
          request[:basic_auth] ||= { username: user, password: password }
        end
      end
    end
  end
end
