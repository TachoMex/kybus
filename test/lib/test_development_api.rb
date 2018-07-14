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

  def jsend_test(status, code, message, http_code, headers = {})
    get("/api/#{status}", headers: headers)
    assert_equal(http_code, last_response.status)
    response = last_json_response
    assert_equal(response['status'], status)
    assert_equal(response['code'], code)
    assert_equal(response['message'], message)
  end

  def basic_auth_test(status, code, http_code, headers)
    get('/api/secret', {}, headers)
    assert_equal(http_code, last_response.status)
    response = last_json_response
    assert_equal(response['status'], status)
    if code.nil?
      assert_nil(response['code'])
      return
    end
    assert_equal(response['code'], code)
  end

  def test_basic_auth
    basic_auth_test('success', nil, 202,
                    'HTTP_AUTHORIZATION' => 'Basic dGVzdDpzZWNyZXQ=')
  end

  def test_basic_auth_wrong_keys
    basic_auth_test('fail', 'AuthenticationError', 401,
                    'HTTP_AUTHORIZATION' => 'Basic OnNlY3JldA==')
  end

  def test_basic_auth_no_keys
    basic_auth_test('fail', 'AuthenticationError', 401, {})
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
