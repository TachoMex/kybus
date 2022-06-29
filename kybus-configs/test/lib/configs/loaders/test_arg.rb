# frozen_string_literal: true

require './test/test_helper'

module Kybus
  module Configuration
    module Loaders
      class TestArg < Minitest::Test
        def test_parse_arguments
          argv = %w[--config_a 1 --config_b --config_c=3
                    --config_d --config_e 5 --verbose --config_z]
          configs = Arg.new('CONFIG', nil, argv).load!
          assert_equal(configs, 'a' => 1, 'b' => true, 'c' => 3,
                                'd' => true, 'e' => 5, 'z' => true)
        end

        def test_flag_at_the_end
          argv = %w[--config_a --verbose]
          configs = Arg.new('CONFIG', nil, argv).load!
          assert_equal(configs, 'a' => true)
        end

        def test_parse_an_object
          argv = %w[--config_obj__a=1 --config_obj__b=2 --config_obj__c 3
                    --config_obj__d --config_obj__e]
          configs = Arg.new('CONFIG', nil, argv).load!
          assert_equal(configs, 'obj' => { 'a' => 1, 'b' => 2, 'c' => 3,
                                           'd' => true, 'e' => true })
        end
      end
    end
  end
end
