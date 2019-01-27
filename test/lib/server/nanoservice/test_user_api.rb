require './test/test_helper'

class TestUserAPI < Minitest::Test
  include Rack::Test::Methods

  def app
    DevelopmentAPI
  end

  def setup
    path = 'storage/users/tachomex.json'
    File.delete(path) if File.file?(path)
  end

  def test_create_user
    post('/api/users', username: 'tachomex', borndate: '2000-01-01',
                       email: 'tacho@tacho.com', mobile: '55555555')
    response = last_json_response
    assert_equal(201, last_response.status)
    assert_equal('success', response['status'])
    assert_equal('tachomex', response['data']['username'])
    'tachomex'
  end

  def test_fetch_user
    id = test_create_user
    get("/api/users/#{id}")
    assert_equal(200, last_response.status)
    data = last_json_response
    assert_equal('success', data['status'])
  end

  def test_fetch_bad_user
    post('/api/users', username: 'tachomex', borndate: '2000-01-01',
                       email: 'tacho_no_mail', mobile: '55555555')
    response = last_json_response
    assert_equal(400, last_response.status)
    assert_equal('fail', response['status'])
  end

  def test_nil_values
    post('/api/users')
    response = last_json_response
    assert_equal(400, last_response.status)
    assert_equal('fail', response['status'])
    assert(response['data'].all? { |_, val| val == ['not_nil failed!'] })
  end
end
