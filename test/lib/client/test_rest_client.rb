require './test/test_helper'
require './lib/ant/client'

module Ant
  module Client
    class TestRESTClient < Minitest::Test
      include Ant::Exceptions
      CONFS = {
        format: :json,
        validator: :jsend,
        endpoint: 'http://api.test'
      }.freeze

      TEST_BODY = {
        status: 'success',
        data: {
          username: 'test'
        }
      }.freeze

      def setup
        @client = RESTClient.new(CONFS)
      end

      def test_verbs
        %i[get post put delete patch].each do |verb|
          stub_request(verb, 'http://api.test/api/users')
            .with(body: { name: 'test', code: '1234' })
            .to_return(body: TEST_BODY.to_json)
          result = @client.send(verb, '/api/users', name: 'test', code: '1234')
          assert_equal(result[:username], 'test')
        end
      end

      def jsend_test(body, verb, path, klass, message = nil)
        stub_request(verb, [CONFS[:endpoint], path].join)
          .to_return(body: body.to_json)
        ex = assert_raises(klass) { @client.send(verb, path) }
        assert_equal(ex.message, body[:message] || message)
        assert_equal(ex.code, body[:code] || 'AntError')
      end

      def test_jsend_fail
        body = { status: 'fail', message: 'Requested user does not exist',
                 code: 'NotFound', data: { username: 'test' } }
        jsend_test(body, :get, '/api/users/test', AntFail)
      end

      def test_jsend_error
        body = { status: 'error',
                 message: 'Can not create user',
                 code: 'Duplicated', data: {} }
        jsend_test(body, :post, '/api/users/test', AntError)
      end

      def test_jsend_unknown
        body = { status: 'crashed',
                 message: nil,
                 return_code: 400, data: {} }
        jsend_test(body, :post, '/do_magic', AntError, 'Unknown Error')
      end

      def test_no_validator
        @client = RESTClient.new(CONFS.merge(validator: :none))
        body = TEST_BODY.merge(status: 'fail')
        stub_request(:get, 'http://api.test/api/users')
          .to_return(body: body.to_json)
        result = @client.get('/api/users')
        assert_equal(body, result)
      end

      def test_url_encoded
        @client = RESTClient.new(CONFS.merge(format: :url_encoded))
        stub_request(:get, 'http://api.test/api/users')
          .with(body: 'name=test&code=1234')
          .to_return(body: TEST_BODY.to_json)
        @client.get('/api/users', name: 'test', code: 1234)
      end

      def test_basic_auth
        conf = CONFS.merge(basic_auth: { user: 'test', password: 'secret' })
        headers = { 'Authorization' => 'Basic dGVzdDpzZWNyZXQ=',
                    'Content-Type' => 'application/json; charset=UTF-8',
                    'User-Agent' => 'Ruby Ant Client' }
        @client = RESTClient.new(conf)
        stub_request(:get, 'http://api.test/api/secret')
          .with(headers: headers)
          .to_return(body: TEST_BODY.to_json)
        @client.get('/api/secret')
      end
    end
  end
end
