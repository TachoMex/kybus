# frozen_string_literal: true

require 'json'

module Kybus
  module Client
    module Validator
      # Implement the empty validator for http client responses.
      class NoValidator
        def validate(response)
          response
        end
      end
    end
  end
end
