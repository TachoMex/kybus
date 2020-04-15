# frozen_string_literal: true

require './test/test_helper'
require './lib/ant/bot'

module Ant
  class TestDebug < Minitest::Test
    include Ant::Bot::Adapter
    def setup
      conf = CONFIG.dup
      conf['provider']['echo'] = false

      @adapter = Ant::Bot::Adapter.from_config(conf['provider'])
    end

    SEND_MSG = 'Sending message to channel: a'

    def test_send_file
      @adapter.echo = true
      methods = { send_video: 'VIDEO',
                  send_audio: 'AUDIO',
                  send_image: 'IMG' }
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
