require_relative '../../../test_helper'

class AutoconfigTest < Minitest::Test
  include Ant::Configuration
  def build_config(confs = {})
    ConfigurationManager.any_instance.expects(:env_vars).returns(confs)
    ConfigurationManager.any_instance.expects(:env_vars).returns({})
    ServiceManager.auto_load!
  end
end
