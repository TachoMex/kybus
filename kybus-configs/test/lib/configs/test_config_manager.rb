# frozen_string_literal: true

require './test/test_helper'

module Kybus
  module Configuration
    class TestConfigurationManager < Minitest::Test
      def test_missing_configs
        conf = ConfigurationManager.new(
          default_files: './config/configs_test.defaults.yaml'
        )
        assert_raises(Configuration::ConfigurationValidator::MissingConfigs) do
          conf.load_configs!
        end
      end
    end
  end
end
