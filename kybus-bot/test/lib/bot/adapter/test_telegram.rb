# frozen_string_literal: true

require './test/test_helper'
require './lib/kybus/bot'

module Kybus
  class TestTelegram < Minitest::Test
    include Kybus::Bot::Adapter
    attr_reader :adapter

    def setup
      @adapter = Kybus::Bot::Adapter.from_config({
                                                   'name' => 'telegram',
                                                   'token' => 'telegram_token'
                                                 })
    end

    def build_photo
      [
        { file_id: 'abcd123',
          file_unique_id: '1234',
          width: 90,
          height: 6,
          file_size: 367 }
      ]
    end

    def default_response(reply = nil, photo = nil)
      from = { 'id' => 1, 'test' => 't', 'username' => 'test', 'is_bot' => false, 'first_name' => 'test',
               'type' => 'group' }
      { 'ok' => true,
        'result' => [{ 'update_id' => 1,
                       'message' =>
                   { 'message_id' => 1,
                     'reply_to_message' => reply,
                     'from' => from,
                     'chat' => from,
                     'photo' => photo,
                     'date' => 1_586_922_532,
                     'text' => 'hi' }.compact }] }
    end

    def unwrap_default_response(response)
      response['result'].first['message']
    end

    def stub_api_query(path: nil, body: {}, response: {})
      ::Telegram::Bot::Api.any_instance.expects(:call).once
                          .with do |endpoint, request|
                            body.each { |k, v| assert_equal(v, request[k]) }
                            assert_equal(endpoint, path)
                          end
                          .returns(response)
    end

    def stub_api_request(method, path, body: {}, response: {}, prefix: '')
      response_body = response.is_a?(String) ? response : response.to_json
      stub_request(method, "https://api.telegram.org/#{prefix}bottelegram_token/#{path}")
        .with(body:)
        .to_return(status: 200, body: response_body, headers: {})
    end

    def test_send_file
      methods = { send_video: 'sendVideo',
                  send_audio: 'sendAudio',
                  send_image: 'sendPhoto',
                  send_document: 'sendDocument' }
      methods.each do |method, path|
        stub_request(:post, "https://api.telegram.org/bottelegram_token/#{path}")
          .to_return(status: 200, body: { ok: true, result: { message_id: 123, date: 123123, chat: { id: 123, type: 'group' }}}.to_json)

        adapter.send(method,
                     'debug_message__a',
                     'Gemfile')
      end
    end

    def test_send_message
      stub_api_query(path: 'sendMessage', response: { 'ok' => true, 'chat_id' => 'user', 'text' => 'Testing', 'result' => { 'message_id' => 1,
                                                                                                                            'date' => 1_586_922_532,
                                                                                                                            'text' => 'hi',
                                                                                                                            'chat' => {
                                                                                                                              id: 123,
                                                                                                                              type: 'group'
                                                                                                                            } } })
      adapter.send_message('user', 'Testing')
    end

    def test_receive_file
      response = default_response(unwrap_default_response(default_response), build_photo)
      stub_api_request(:post, 'getUpdates', response:)

      msg = adapter.read_message
      assert(msg.reply?)
      assert(msg.has_attachment?)
      file = TelegramFile.new(msg.attachment)
      assert(msg.replied_message)
      stub_api_request(:post, 'getFile', body: { 'file_id' => 'abcd123' },
                                         response: { result: { file_path: 'hello.txt', file_id: 'abasde', file_unique_id: '123123' } })
      stub_api_request(:get, 'hello.txt', response: 'hello-world', prefix: 'file/')
      assert_equal(file.download, 'hello-world')
    end

    def test_read_message
      response = default_response
      stub_api_query(path: 'getUpdates', response:)
      msg = adapter.read_message
      assert_equal(msg.raw_message, 'hi')
      assert_equal(msg.channel_id, 1)
      assert_equal(msg.is_private?, false)
      assert_equal(msg.has_attachment?, false)
      assert_equal(msg.user, 1)
      refute(msg.reply?)
    end

    def test_file_storage
      response = default_response(unwrap_default_response(default_response), build_photo)
      stub_api_request(:post, 'getUpdates', response:)
      msg = adapter.read_message
      stub_api_request(:post, 'getFile', body: { 'file_id' => 'abcd123' },
                                         response: { result: { file_path: 'hello.txt', file_id: 'abcd123', file_unique_id: '12312' } })

      file = TelegramFile.new(msg.attachment)
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
