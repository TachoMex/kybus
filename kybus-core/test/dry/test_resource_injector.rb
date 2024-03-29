# frozen_string_literal: true

require './test/test_helper'

module Kybus
  module DRY
    class TestResourceInjector < Minitest::Test
      extend ResourceInjector
      def test_store_and_retrieve
        self.class.register(:magic_number, 42)
        self.class.register(:passwords, :database, 'secret')

        assert_equal(42, self.class.resource(:magic_number))
        assert_equal(42, self.class.resource(:root, :magic_number))
        assert_equal('secret', self.class.resource(:passwords, :database))
        assert_nil(self.class.unsafe_resource(:not_found))
      end
    end
  end
end
