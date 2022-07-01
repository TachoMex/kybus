# frozen_string_literal: true

require './test/test_helper'
require './lib/kybus/bot'

module Kybus
  class TestDebug < Minitest::Test
    include Kybus::Bot::Adapter
    def setup
      conf = CONFIG.dup
      conf['provider']['echo'] = false

      @adapter = Kybus::Bot::Adapter.from_config(conf['provider'])
    end

    SEND_MSG = 'Sending message to channel: a'

    def test_debug_channel_has_user
      message = @adapter.read_message
      assert_equal(message.user, 'debug_message__a')
    end

    def test_send_file
      @adapter.echo = true
      methods = { send_video: 'VIDEO',
                  send_audio: 'AUDIO',
                  send_image: 'IMG',
                  send_document: 'DOC' }
      methods.each do |method, tag|
        msg = "#{tag}: file:///home/user/video.mp4"
        Channel.any_instance.expects(:puts).with(SEND_MSG)
        Channel.any_instance.expects(:puts).with(msg)
        @adapter.send(method,
                      'debug_message__a',
                      'file:///home/user/video.mp4')
      end
    end
  end
end
