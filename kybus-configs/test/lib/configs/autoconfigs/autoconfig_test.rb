# frozen_string_literal: true

require_relative '../../../test_helper'

class AutoconfigTest < Minitest::Test
  include Kybus::Configuration

  def delete_file(path)
    FileUtils.rm_rf(path)
  end

  def mock_aws
    Aws::InstanceProfileCredentials.any_instance.stubs(:get_credentials).returns('{}')
  end

  def build_config(confs = {})
    ConfigurationManager.expects(:auto_load!).returns(confs)
    ServiceManager.auto_load!
  end
end
