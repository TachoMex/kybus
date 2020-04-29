# frozen_string_literal: true

require './test/test_helper'

module Kybus
  module Nanoservice
    class TestValidator < Minitest::Test
      def test_keys_validator
        validator = Validator.validator('keys').curry(nil)
        assert(validator.call('hello'))
        assert(validator.call(1))
        assert(validator.call(nil))
      end

      def test_range_validator
        validator = Validator.validator('range')
                             .curry
                             .call('min' => 10, 'max' => 20)
        assert_nil(validator.call(15))
        refute_nil(validator.call(1))
        assert_nil(validator.call(nil))
      end
    end
  end
end
