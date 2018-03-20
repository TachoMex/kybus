require 'rack'

require './development_api'
require 'ant/client'

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
    @client = Ant::Client::RESTClient.new(CONFS)
    @server = Thread.new { Rack::Server.start }
    @expectations = Hash[EXPECTATIONS.collect { |k| [k, false] }]
  end

  def assert(expectation)
    @expectations[expectation] = true
  end

  def test_verbs
    ap @client.get('/api/status')
    assert(:status)
    %w[fail error fatal].each do |status|
      begin
        @client.get("/api/#{status}")
      rescue Ant::Exceptions::AntBaseException => _
        assert(status.to_sym)
      end
    end
  end

  def test_basic_auth
    begin
      @client.get('/api/secret')
    rescue Ant::Exceptions::AntFail => _
      assert(:no_keys)
    end
    begin
      conf = CONFS.merge(basic_auth: { user: 'test', password: 'no_secret' })
      client = Ant::Client::RESTClient.new(conf)
      client.get('/api/secret')
    rescue Ant::Exceptions::AntFail => _
      assert(:auth_failed)
    end
    conf = CONFS.merge(basic_auth: { user: 'test', password: 'secret' })
    client = Ant::Client::RESTClient.new(conf)
    data = client.get('/api/secret')
    assert(:auth) if data[:money] == 1000
  end

  def execute
    # await for api to load
    sleep(5)
    test_verbs
    test_basic_auth
    ap(@expectations)
    exit(1) unless @expectations.values.all?
    exit(0)
  end
end

TestClientWithServer.new.execute if $PROGRAM_NAME == __FILE__
