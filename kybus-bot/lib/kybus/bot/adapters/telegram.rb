# frozen_string_literal: true

require 'telegram/bot'

module Kybus
  module Bot
    # :nodoc: #
    module Adapter
      # :nodoc: #
      # Wraps a debugging message inside a class.
      class TelegramMessage < Kybus::Bot::Message
        # It receives a string with the raw text and the id of the channel
        def initialize(message)
          @message = message
        end

        # Returns the channel id
        def channel_id
          @message.from.id
        end

        # Returns the message contents
        def raw_message
          @message.to_s
        end
      end

      ##
      # This adapter is intended to be used on unit tests and development.
      class Telegram
        include ::Kybus::Logger
        # It receives a hash with the configurations:
        # - name: the name of the channel
        # - channels a key value, where the key is a name and the value the
        #   list of the messages in the channel.
        # - echo: a flag to enable debug messages.
        def initialize(configs)
          @config = configs
          @client = ::Telegram::Bot::Client.new(@config['token'])
        end

        # Interface for receiving message
        def read_message
          # take the first message from the first open message,
          @client.listen do |message|
            log_info('Received message', message: message.to_h,
                                         from: message.from.to_h)
            return TelegramMessage.new(message)
          end
        end

        # interface for sending messages
        def send_message(channel_name, contents)
          @client.api.send_message(chat_id: channel_name, text: contents)
        rescue Telegram::Bot::Exceptions::ResponseError => err
          return if err[:error_code] == '403'
        end

        # interface for sending video
        def send_video(channel_name, video_url)
          file = Faraday::UploadIO.new(video_url, 'video/mp4')
          @client.api.send_video(chat_id: channel_name, audio: file)
        end

        # interface for sending uadio
        def send_audio(channel_name, audio_url)
          file = Faraday::UploadIO.new(audio_url, 'audio/mp3')
          @client.api.send_audio(chat_id: channel_name, audio: file)
        end

        # interface for sending image
        def send_image(channel_name, image_url)
          file = Faraday::UploadIO.new(image_url, 'image/jpeg')
          @client.api.send_photo(chat_id: channel_name, photo: file)
        end
      end

      register('telegram', Telegram)
    end
  end
end
