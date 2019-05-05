# frozen_string_literal: true

require './test/test_helper'

module Ant
  module Configuration
    class TestConfigurationManager < Minitest::Test
      def test_missing_configs
        conf = ConfigurationManager.new(
          default_files: './config/configs_test.defaults.yaml'
        )
        assert_raises(ConfigurationManager::MissingConfigs) do
          conf.load_configs!
        end
      end
    end
  end
end
