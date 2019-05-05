# frozen_string_literal: true

require './test/test_helper'

class TestTuplesAPI < Minitest::Test
  include Rack::Test::Methods

  def app
    DevelopmentAPI
  end

  def setup
    path = 'storage/tuples/user.json'
    File.delete(path) if File.file?(path)
  end

  def create(key, value, repository = 'json')
    post("/api/nanoservice/#{repository}/tuples/#{key}", value: value)
    response = last_json_response
    assert_equal(201, last_response.status)
    assert_equal('success', response['status'])
    assert_equal(value, response['data']['value'])
    response['data']
  end

  def test_create_json
    data = create('user', 'tacho')
    get('/api/nanoservice/json/tuples/user')
    response = last_json_response
    assert_equal(200, last_response.status)
    assert_equal(data, response['data'])
  end
end
