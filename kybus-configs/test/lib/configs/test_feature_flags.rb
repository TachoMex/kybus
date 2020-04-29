# frozen_string_literal: true

require './test/test_helper'

module Kybus
  module Configuration
    class TestFeaturFlags < Minitest::Test
      def setup
        @configs ||= Kybus::Configuration.auto_load!
        nil
      end

      def test_feature_flags_are_on
        (1..5).each { |i| assert(@configs.features[:"on_#{i}"]) }
      end

      def test_feature_flags_are_off
        (1..5).each { |i| refute(@configs.features[:"off_#{i}"]) }
      end

      def count_test(experiments, lower, upper, feature)
        count = 0
        experiments.times { count += 1 if @configs.features[feature] }
        assert(count <= upper)
        assert(count >= lower)
      end

      def test_ab_testing
        count_test(1000, 50, 150, :ab_test_10)
        count_test(1000, 450, 550, :ab_test_50)
      end

      def test_canarying
        count_test(1000, 50, 150, :canarying_1)
        sleep(5)
        count_test(1000, 50, 150, :canarying_1)
        sleep(7)
        count_test(1000, 150, 250, :canarying_1)
      end
    end
  end
end
