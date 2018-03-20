require './test/test_helper'

module Ant
  module Server
    class API < Grape::API
      helpers Response
      format(:json)

      get :test do
        process_request do
          { value: 'Just a string' }
        end
      end

      get :fatal do
        process_request { raise('I do not know what happened') }
      end

      get :fail do
        process_request { raise(Ant::Exceptions::AntFail, 'Wrong Value') }
      end

      get :badapp do
        process_request { raise(SyntaxError, 'Expected `;`') }
      end

      get :error do
        process_request do
          raise(Ant::Exceptions::AntError, 'The system crashed')
        end
      end
    end

    class TestResponse < Minitest::Test
      include Rack::Test::Methods

      def app
        API
      end

      def test_process_request
        data = { 'value' => 'Just a string' }
        get('/test')
        response = last_json_response
        assert_equal(response, 'status' => 'success', 'data' => data)

        %w[fail error fatal].each do |status|
          get("/#{status}")
          response = last_json_response
          assert_equal(status, response['status'])
        end
      end

      def test_exception
        assert_raises(SyntaxError) { get('/badapp') }
      end
    end
  end
end
