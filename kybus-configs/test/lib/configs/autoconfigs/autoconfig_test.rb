# frozen_string_literal: true

require_relative '../../../test_helper'

class AutoconfigTest < Minitest::Test
  include Kybus::Configuration

  def delete_file(path)
    File.delete(path) if File.exist?(path)
  end

  def build_config(confs = {})
    ConfigurationManager.any_instance.expects(:env_vars).returns(confs)
    ConfigurationManager.any_instance.expects(:env_vars).returns({})
    ServiceManager.auto_load!
  end
end