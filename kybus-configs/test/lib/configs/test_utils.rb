# frozen_string_literal: true

require './test/test_helper'

module Kybus
  module Configuration
    class TestUtils < Minitest::Test
      include Utils
      def test_array_wrap
        assert_equal(%w[hello], array_wrap('hello'))
        assert_equal(%w[hello], array_wrap(%w[hello]))
      end

      def test_recursive_merge
        a = { a: 1, b: { c: 2 }, f: %i[a b c d] }
        b = { b: { d: 3 }, e: 4, f: %i[a b c] }
        assert_equal(recursive_merge(a, b), a: 1, b: { c: 2, d: 3 },
                                            e: 4, f: %i[a b c])
      end

      def test_parse_type
        assert_equal(parse_type('123'), 123)
        assert_equal(parse_type('123_'), '123_')
      end
    end
  end
end
