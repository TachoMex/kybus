# frozen_string_literal: true

require './test/test_helper'
require './lib/kybus/bot'

module Kybus
  class TestTelegram < Minitest::Test
    include Kybus::Bot::Adapter
    def setup
      conf = CONFIG.dup
      conf['provider'] = {
        'name' => 'telegram',
        'token' => 'telegram_token'
      }

      @adapter = Kybus::Bot::Adapter.from_config(conf['provider'])
    end

    def stub_api_query(path: nil, body: {}, response: {})
      ::Telegram::Bot::Api.any_instance.expects(:call)
                          .with do |endpoint, request|
                            body.each { |k, v| assert_equal(v, request[k]) }
                            assert_equal(endpoint, path)
                          end
                          .returns(response)
    end

    def test_send_file
      methods = { send_video: 'sendVideo',
                  send_audio: 'sendAudio',
                  send_image: 'sendPhoto' }
      methods.each do |method, path|
        stub_request(:post, "https://api.telegram.org/bottelegram_token/#{path}")
          .to_return(status: 200, body: {}.to_json)

        @adapter.send(method,
                      'debug_message__a',
                      'Gemfile')
      end
    end

    def test_send_message
      stub_api_query(path: 'sendMessage', body: { chat_id: 'user', text: 'Testing' })
      @adapter.send_message('user', 'Testing')
    end

    def test_read_message
      from = { 'id' => 1, 'test' => 't', 'username' => 'test' }
      response = { 'ok' => true,
                   'result' => [{ 'update_id' => 1,
                                  'message' =>
                   { 'message_id' => 1,
                     'from' => from,
                     'chat' => from,
                     'date' => 1_586_922_532,
                     'text' => 'hi' } }] }

      stub_api_query(path: 'getUpdates', response: response)
      msg = @adapter.read_message
      assert_equal(msg.raw_message, 'hi')
      assert_equal(msg.channel_id, 1)
    end
  end
end
