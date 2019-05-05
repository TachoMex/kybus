# frozen_string_literal: true

module Ant
  module Bot
    module Adapter
      # Interface for connecting with telegram api
      # TODO: Implement this
      class Telegram
        def initialize(configs); end

        # Interface for receiving message
        def read_message
          raise
        end

        # interface for sending messages
        def send_message(_channel, _contents)
          raise
        end

        # interface for sending video
        def send_video(_channel, _video_url)
          raise
        end

        # interface for sending uadio
        def send_audio(_channel, _audio_url)
          raise
        end

        # interface for sending image
        def send_image(_channel, _image_url)
          raise
        end
      end
    end
  end
end
