require 'json'

module Ant
  module Client
    module Validator
      class NoValidator
        def validate(response)
          response
        end
      end
    end
  end
end
