# frozen_string_literal: true

require_relative 'autoconfig_test'

class TestLogger < AutoconfigTest
  def setup
    delete_file('app.log')
  end

  def test_logger
    conf = YAML.load_file('./config/log.yaml')
    conf = build_config(conf)

    log = conf.services('logger')
    log.log_info('Hello World', pass: 1234)
    string = File.read('app.log')
    assert(string.include?('----'))
    refute(string.include?('1234'))
    refute(string.include?('WARN'))
    assert(string.include?('INFO'))
  end
end
