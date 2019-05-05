# frozen_string_literal: true

require_relative 'validator/jsend'
require_relative 'validator/no_validator'

module Ant
  module Client
    # Allows to validate the responses from another service.
    # Use it to rise exceptions when you detect there were an error.
    module Validator
      class << self
        def build(config)
          config[:validator] ||= :none
          @validators ||= default_validators
          @validators[config[:validator]].new
        end

        def default_validators
          {
            jsend: JSend,
            empty: NoValidator,
            none: NoValidator
          }
        end
      end
    end
  end
end
