# frozen_string_literal: true

require_relative 'autoconfig_test'
require 'aws-sdk-s3'

class TestS3 < AutoconfigTest
  def test_s3_loader
    conf = YAML.load_file('./config/s3.yaml')
    conf = build_config(conf)
    assert(conf.services('aws', 's3', 'log_record'))
  end
end
