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

    def test_send_media_with_parse_mode_and_caption
      adapter_with_mode = Kybus::Bot::Adapter.from_config('name' => 'telegram', 'token' => TELEGRAM_TOKEN,
                                                          'parse_mode' => 'MarkdownV2')
      ::Telegram::Bot::Api.any_instance.expects(:send_video).with do |request|
        assert_equal('debug_message__a', request[:chat_id])
        assert_equal('cap', request[:caption])
        assert_equal('MarkdownV2', request[:parse_mode])
        assert(request[:video].is_a?(Faraday::FilePart))
      end
      ::Telegram::Bot::Api.any_instance.expects(:send_audio).with do |request|
        assert_equal('debug_message__a', request[:chat_id])
        assert_equal('cap', request[:caption])
        assert_equal('MarkdownV2', request[:parse_mode])
        assert(request[:audio].is_a?(Faraday::FilePart))
      end
      ::Telegram::Bot::Api.any_instance.expects(:send_photo).with do |request|
        assert_equal('debug_message__a', request[:chat_id])
        assert_equal('cap', request[:caption])
        assert_equal('MarkdownV2', request[:parse_mode])
        assert(request[:photo].is_a?(Faraday::FilePart))
      end
      ::Telegram::Bot::Api.any_instance.expects(:send_document).with do |request|
        assert_equal('debug_message__a', request[:chat_id])
        assert_equal('cap', request[:caption])
        assert_equal('MarkdownV2', request[:parse_mode])
        assert(request[:document].is_a?(Faraday::FilePart))
      end

      adapter_with_mode.send_video('debug_message__a', 'Gemfile', 'cap')
      adapter_with_mode.send_audio('debug_message__a', 'Gemfile', 'cap')
      adapter_with_mode.send_image('debug_message__a', 'Gemfile', 'cap')
      adapter_with_mode.send_document('debug_message__a', 'Gemfile', 'cap')
    end

    def test_send_media_ignores_403
      error = build_response_error(403)
      ::Telegram::Bot::Api.any_instance.expects(:send_video).raises(error)
      ::Telegram::Bot::Api.any_instance.expects(:send_audio).raises(error)
      ::Telegram::Bot::Api.any_instance.expects(:send_photo).raises(error)
      ::Telegram::Bot::Api.any_instance.expects(:send_document).raises(error)

      assert_nil(adapter.send_video('debug_message__a', 'Gemfile', 'cap'))
      assert_nil(adapter.send_audio('debug_message__a', 'Gemfile', 'cap'))
      assert_nil(adapter.send_image('debug_message__a', 'Gemfile', 'cap'))
      assert_nil(adapter.send_document('debug_message__a', 'Gemfile', 'cap'))
    end

    def test_handle_message_parses_reply_and_attachment
      payload = {
        'message' => {
          'chat' => { 'id' => 123, 'type' => 'private' },
          'message_id' => 10,
          'from' => { 'username' => 'u' },
          'text' => '/hi',
          'reply_to_message' => {
            'chat' => { 'id' => 123, 'type' => 'private' },
            'message_id' => 9,
            'from' => { 'username' => 'u2' },
            'text' => 'prev'
          },
          'photo' => PHOTO_JSON
        }
      }

      msg = adapter.handle_message(payload)
      assert_equal('/hi', msg.raw_message)
      assert_equal(123, msg.channel_id)
      assert_equal(true, msg.is_private?)
      assert(msg.reply?)
      assert(msg.has_attachment?)
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

    def build_response_error(code)
      env = Struct.new(:url).new(URI('http://example.test'))
      response = Struct.new(:body, :status, :env).new({ error_code: code }.to_json, code, env)
      ::Telegram::Bot::Exceptions::ResponseError.new(response:)
    end
  end
end
