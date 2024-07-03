# frozen_string_literal: true

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

  def assert_with_nil(val_a, val_b)
    if val_b.nil?
      assert_nil(val_a)
    else
      assert_equal(val_a, val_b)
    end
  end

  def jsend_test(status, code, message, http_code, headers = {})
    get("/api/#{status}", headers:)
    assert_equal(http_code, last_response.status)
    response = last_json_response
    assert_equal(response['status'], status)
    assert_with_nil(response['code'], code)
    assert_with_nil(response['message'], message)
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
    basic_auth_test('fail', 'Unauthorized', 401,
                    'HTTP_AUTHORIZATION' => 'Basic OnNlY3JldA==')
  end

  def test_basic_auth_no_keys
    basic_auth_test('fail', 'Unauthorized', 401, {})
  end

  def test_fail
    jsend_test('fail', 'BadRequest', 'Wrong Value', 400)
  end

  def test_slow
    get('/api/slow')
    assert_equal(200, last_response.status)
    response = last_json_response
    assert_equal(response['status'], 'success')
  end

  def test_error
    jsend_test('error', 'KybusError', 'The system crashed', 500)
  end

  def test_success
    jsend_test('success', nil, nil, 200)
  end

  def test_fatal
    jsend_test('fatal', 'INTERNAL_SERVER_ERROR',
               'Unexpected error ocurred!', 500)
  end
end
