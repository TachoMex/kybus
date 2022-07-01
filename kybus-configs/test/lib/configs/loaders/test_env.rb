# frozen_string_literal: true

require './test/test_helper'

module Kybus
  module Configuration
    module Loaders
      class TestEnv < Minitest::Test
        def test_parse_vars
          env = {
            'UTEST_A' => '1',
            'UTEST_B' => 'false',
            'UTEST_C' => 'true'
          }
          data = Env.new('UTEST', env).load!
          assert_equal(data['a'], 1)
          assert_equal(data['b'], false)
          assert_equal(data['c'], true)
        end

        def test_parse_vars_array
          env = {
            'UTEST_A' => '1,2,3',
            'UTEST_B' => '2',
            'UTEST_C' => '3'
          }
          data = Env.new('UTEST', env).load!
          assert_equal(data['a'], [1, 2, 3])
          assert_equal(data['b'], 2)
          assert_equal(data['c'], 3)
        end

        def test_parse_vars_objec
          env = {
            'UTEST_OBJ__A' => 1,
            'UTEST_OBJ__B' => 2,
            'UTEST_OBJ__C' => 3
          }
          data = Env.new('UTEST', env).load!
          assert_equal(data['obj']['a'], 1)
          assert_equal(data['obj']['b'], 2)
          assert_equal(data['obj']['c'], 3)
        end
      end
    end
  end
end
