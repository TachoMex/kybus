require_relative 'validator/jsend'
require_relative 'validator/no_validator'

module Ant
  module Client
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
