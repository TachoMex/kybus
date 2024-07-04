# frozen_string_literal: true

require './test/test_helper'
require './lib/kybus/bot'

module Kybus
  TELEGRAM_API_URL = 'https://api.telegram.org'
  TELEGRAM_TOKEN = 'telegram_token'
  TELEGRAM_BOT_PREFIX = "bot#{TELEGRAM_TOKEN}/".freeze
  CHAT_JSON = { 'id' => 123, 'type' => 'group' }.freeze
  FILE_JSON = { 'file_path' => 'hello.txt', 'file_id' => 'abasde', 'file_unique_id' => '123123',
                'file_size' => 523 }.freeze
  PHOTO_JSON = [{ file_id: 'abcd123', file_unique_id: '1234', width: 90, height: 6, file_size: 367 }].freeze
  FROM_JSON = { 'id' => 1, 'test' => 't', 'username' => 'test', 'is_bot' => false, 'first_name' => 'test',
                'type' => 'group' }.freeze
  MESSAGE_JSON = { 'message_id' => 1, 'from' => FROM_JSON, 'chat' => FROM_JSON, 'date' => 1_586_922_532,
                   'text' => 'hi' }.freeze
  SEND_FILE_METHODS = { send_video: 'sendVideo', send_audio: 'sendAudio', send_image: 'sendPhoto',
                        send_document: 'sendDocument' }.freeze

  class TestTelegram < Minitest::Test
    include Kybus::Bot::Adapter
    attr_reader :adapter

    def setup
      @adapter = Kybus::Bot::Adapter.from_config('name' => 'telegram', 'token' => TELEGRAM_TOKEN)
    end

    def default_response(reply = nil, photo = nil)
      {
        'ok' => true,
        'result' => [{ 'update_id' => 1,
                       'message' => MESSAGE_JSON.merge('reply_to_message' => reply, 'photo' => photo).compact }]
      }
    end

    def unwrap_default_response(response)
      response.dig('result', 0, 'message')
    end

    def stub_api_query(path:, body: {}, response: {})
      ::Telegram::Bot::Api.any_instance.expects(:call).once.with do |endpoint, request|
        assert_equal(path, endpoint)
        body.each { |k, v| assert_equal(v, request[k]) }
      end.returns(response)
    end

    def stub_api_request(method, path, body: {}, response: {}, prefix: '')
      response_body = response.is_a?(String) ? response : response.to_json
      url = "#{TELEGRAM_API_URL}/#{prefix}#{TELEGRAM_BOT_PREFIX}#{path}"
      stub_request(method, url).with(body:).to_return(status: 200, body: response_body, headers: {})
    end

    def test_send_file
      SEND_FILE_METHODS.each do |method, path|
        stub_send_file_request(path)
        adapter.send(method, 'debug_message__a', 'Gemfile')
      end
    end

    def stub_send_file_request(path)
      stub_request(:post, "#{TELEGRAM_API_URL}/#{TELEGRAM_BOT_PREFIX}#{path}")
        .to_return(status: 200, body: { ok: true,
                                        result: { message_id: 123, date: 123_123, chat: CHAT_JSON } }.to_json)
    end

    def test_send_message
      stub_api_query(path: 'sendMessage', response: {
                       'ok' => true,
                       'chat_id' => 'user',
                       'text' => 'Testing',
                       'result' => {
                         'message_id' => 1, 'date' => 1_586_922_532, 'text' => 'hi', 'chat' => CHAT_JSON
                       }
                     })
      adapter.send_message('user', 'Testing')
    end

    def test_receive_file
      response = default_response(unwrap_default_response(default_response), PHOTO_JSON)
      stub_api_request(:post, 'getUpdates', response:)

      msg = adapter.read_message
      assert_received_message_with_attachment(msg)
    end

    def assert_received_message_with_attachment(msg)
      assert(msg.reply?)
      assert(msg.has_attachment?)
      file = TelegramFile.new(msg.attachment)
      assert(msg.replied_message)
      stub_api_request(:post, 'getFile', body: { 'file_id' => 'abcd123' }, response: { result: FILE_JSON })
      stub_api_request(:get, 'hello.txt', response: 'hello-world', prefix: 'file/')
      assert_equal(file.download, 'hello-world')
    end

    def test_read_message
      response = default_response
      stub_api_query(path: 'getUpdates', response:)
      msg = adapter.read_message
      assert_default_message_properties(msg)
    end

    def assert_default_message_properties(msg)
      assert_equal('hi', msg.raw_message)
      assert_equal(1, msg.channel_id)
      assert_equal(false, msg.is_private?)
      assert_equal(false, msg.has_attachment?)
      assert_equal(1, msg.user)
      refute(msg.reply?)
    end

    def test_file_storage
      response = default_response(unwrap_default_response(default_response), PHOTO_JSON)
      stub_api_request(:post, 'getUpdates', response:)
      msg = adapter.read_message
      stub_api_request(:post, 'getFile', body: { 'file_id' => 'abcd123' }, response: { result: FILE_JSON })

      file = TelegramFile.new(msg.attachment)
      assert_telegram_file_properties(file)
    end

    def assert_telegram_file_properties(file)
      assert(file.original_name)
      assert(file.to_h)
      assert(TelegramFile.new(file.to_h))
      assert(TelegramFile.new(file))
      assert(adapter.file_builder(file.id))
    end

    def test_mention
      response = default_response
      stub_api_request(:post, 'getUpdates', response:)
      message = adapter.read_message
      assert_equal('[user](tg://user?id=1)', adapter.mention(message.user))
    end
  end
end
