# frozen_string_literal: true

require_relative 'validator/jsend'
require_relative 'validator/no_validator'

module Ant
  module Client
    # Allows to validate the responses from another service.
    # Use it to rise exceptions when you detect there were an error.
    module Validator
      extend Ant::DRY::ResourceInjector

      class << self
        def build(config)
          resource(:validators, config[:validator] || 'empty').new
        end

        def register_validator(name, klass)
          register(:validators, name, klass)
        end

      end
      register_validator('jsend', JSend)
      register_validator('empty', NoValidator)
      register_validator('none', NoValidator)
    end
  end
end
