# frozen_string_literal: true

require 'telegram/bot'
require 'faraday'
require_relative 'telegram_file'
require_relative 'telegram_message'

module Kybus
  module Bot
    module Adapter
      ##
      # This adapter is intended to be used on unit tests and development.
      class Telegram
        include ::Kybus::Logger

        attr_reader :last_message

        # It receives a hash with the configurations:
        # - name: the name of the channel
        # - channels a key value, where the key is a name and the value the
        #   list of the messages in the channel.
        # - echo: a flag to enable debug messages.
        def initialize(configs)
          @config = configs
          @client = ::Telegram::Bot::Client.new(@config['token'])
          TelegramFile.register(:cli, @client)
        end

        # Interface for receiving message
        def read_message
          # take the first message from the first open message,
          loop do
            @client.listen do |message|
              log_info('Received message', message: message.to_h,
                                           from: message.from.to_h)
              return @last_message = TelegramMessage.new(message)
            end
          rescue ::Telegram::Bot::Exceptions::ResponseError => e
            # :nocov:
            log_error('An error ocurred while calling to Telegram API', e)
            # :nocov:
          end
        end

        def mention(id)
          "[user](tg://user?id=#{id})"
        end

        # interface for sending messages
        def send_message(channel_name, contents)
          puts "#{channel_name} => #{contents}" if @config['debug']
          @client.api.send_message(chat_id: channel_name, text: contents)
          # :nocov:
        rescue ::Telegram::Bot::Exceptions::ResponseError => e
          return if e[:error_code] == '403'
        end
        # :nocov:

        # interface for sending video
        def send_video(channel_name, video_url, comment = nil)
          file = Faraday::FilePart.new(video_url, 'video/mp4')
          @client.api.send_video(chat_id: channel_name, video: file, caption: comment)
        end

        # interface for sending uadio
        def send_audio(channel_name, audio_url)
          file = Faraday::FilePart.new(audio_url, 'audio/mp3')
          @client.api.send_audio(chat_id: channel_name, audio: file)
        end

        # interface for sending image
        def send_image(channel_name, image_url, comment = nil)
          file = Faraday::FilePart.new(image_url, 'image/jpeg')
          @client.api.send_photo(chat_id: channel_name, photo: file, caption: comment)
        end

        # interface for sending document
        def send_document(channel_name, image_url)
          file = Faraday::FilePart.new(image_url, 'application/octect-stream')
          @client.api.send_document(chat_id: channel_name, document: file)
        end

        def message_builder(raw_message)
          TelegramMessage.new(raw_message)
        end

        def file_builder(file)
          TelegramFile.new(file)
        end
      end

      register('telegram', Telegram)
    end
  end
end
