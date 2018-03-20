require './test/test_helper'

class TestDevelopmentAPI < Minitest::Test
  include Rack::Test::Methods

  def app
    DevelopmentAPI
  end

  def test_status
    get('/api/status')
    assert_equal(200, last_response.status)
    response = last_json_response
    assert_equal(response['status'], 'success')
  end

  def jsend_test(status, code, message, http_code)
    get("/api/#{status}")
    assert_equal(http_code, last_response.status)
    response = last_json_response
    assert_equal(response['status'], status)
    assert_equal(response['code'], code)
    assert_equal(response['message'], message)
  end

  def test_fail
    jsend_test('fail', 'AntFail', 'Wrong Value', 400)
  end

  def test_error
    jsend_test('error', 'AntError', 'The system crashed', 500)
  end

  def test_fatal
    jsend_test('fatal', 'INTERNAL_SERVER_ERROR',
               'Unexpected error ocurred!', 500)
  end
end
