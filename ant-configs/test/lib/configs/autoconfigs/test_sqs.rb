# frozen_string_literal: true

require_relative 'autoconfig_test'
require 'aws-sdk-sqs'

class TestSQS < AutoconfigTest
  def test_sqs_loader
    mock = { queue_url: 'aws.sqs/ant-mailing' }
    conf = YAML.load_file('./config/sqs.yaml')
    ::Aws::SQS::Client.any_instance
                      .expects(:get_queue_url)
                      .with(queue_name: 'ant-mailing')
                      .returns(mock)
    conf = build_config(conf)
    assert_equal(conf.services('aws', 'sqs', 'mailing').url, mock[:queue_url])
  end
end
