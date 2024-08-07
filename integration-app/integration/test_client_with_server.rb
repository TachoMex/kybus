# frozen_string_literal: true

require 'rack'

require './development_api'
require 'kybus/client'

##
# Runs an integration test by validating that the development api can be queried
# correctly and that it returns the expected values
class TestClientWithServer
  CONFS = {
    format: :json,
    validator: :jsend,
    endpoint: 'http://127.0.0.1:8888'
  }.freeze

  EXPECTATIONS = %i[status fail error fatal auth auth_failed no_keys].freeze

  def initialize
    @client = Kybus::Client::RESTClient.new(CONFS)
    @server = Thread.new { Rack::Server.start }
    @expectations = EXPECTATIONS.to_h { |k| [k, false] }
  end

  def assert(expectation)
    @expectations[expectation] = true
  end

  def test_verbs
    ap @client.get('/api/status')
    assert(:status)
    %w[fail error fatal].each do |status|
      @client.get("/api/#{status}")
    rescue Kybus::Exceptions::KybusBaseException => _e
      assert(status.to_sym)
    end
  end

  def test_basic_auth_empty_keys
    @client.get('/api/secret')
  rescue Kybus::Exceptions::KybusFail => _e
    assert(:no_keys)
  end

  def test_basic_auth_fails
    conf = CONFS.merge(basic_auth: { user: 'test', password: 'no_secret' })
    client = Kybus::Client::RESTClient.new(conf)
    client.get('/api/secret')
  rescue Kybus::Exceptions::KybusFail => _e
    assert(:auth_failed)
  end

  def test_basic_auth_success
    conf = CONFS.merge(basic_auth: { user: 'test', password: 'secret' })
    client = Kybus::Client::RESTClient.new(conf)
    data = client.get('/api/secret')
    assert(:auth) if data[:money] == 1000
  end

  def test_basic_auth_cases
    test_basic_auth_fails
    test_basic_auth_empty_keys
    test_basic_auth_success
  end

  def execute
    # await for api to load
    sleep(5)
    test_verbs
    test_basic_auth_success
    ap(@expectations)
    exit(1) unless @expectations.values.all?
    exit(0)
  end
end

TestClientWithServer.new.execute if $PROGRAM_NAME == __FILE__
