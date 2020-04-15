class TestLogger < Minitest::Test
  include Ant::Logger

  def setup
    erase_file
  end

  def erase_file(path = 'application.log')
    File.delete(path) if File.file?(path)
  end

  def build_logger(conf = {})
    LogMethods.global_config = Config.new(conf)
  end

  def read_log(path = 'application.log')
    File.read(path)
  end

  def test_debug_mode
    build_logger('severity' => 'debug')
    log_debug('Some added value', debug: 'hello', pass: '1234', user: 'test')
    string = read_log
    refute(string.include?('1234'))
    assert(string.include?('hello'))
    assert(string.include?('test'))
    assert(string.include?('Some added value'))
    assert(string.include?('DEBUG'))
  end

  def check_default_log_test(sev_identifier, file = 'application.log')
    string = read_log(file)
    refute(string.include?('1234'))
    refute(string.include?('hello'))
    refute(string.include?('Invisible'))
    assert(string.include?('test'))
    assert(string.include?('Some added value'))
    assert(string.include?(sev_identifier))
  end

  def test_black_listing_messages
    methods = {
      log_info: 'INFO',
      log_warn: 'WARN',
      log_error: 'ERROR',
      log_fatal: 'FATAL'
    }
    methods.each do |method, sev|
      build_logger
      log_debug('Invisible message')
      send(method, 'Some added value',
           debug: 'hello', pass: '1234', user: 'test')
      check_default_log_test(sev)
      setup
    end
  end

  def test_log_metric
    build_logger
    log_metric(metric: 'test_executed', amount: 1, group: 'unit_testing')
    string = read_log
    assert(string.include?('INFO'))
    assert(string.include?('test_executed'))
    assert(string.include?('unit_testing'))
  end

  def test_log_alert
    build_logger
    log_alert(description: 'test_executed',
               alert_severity: 1, group: 'unit_testing', notify_group: 'sre')
    string = read_log
    assert(string.include?('FATAL'))
    assert(string.include?('test_executed'))
    assert(string.include?('unit_testing'))
  end

  def test_change_file_name
    erase_file('app.log')
    build_logger('file' => 'app.log')
    log_info('Some added value', test: true)
    check_default_log_test('INFO', 'app.log')
  end
end
