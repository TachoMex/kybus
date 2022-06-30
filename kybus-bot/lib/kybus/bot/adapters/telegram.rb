# frozen_string_literal: true

require 'telegram/bot'
require 'faraday'

module Kybus
  module Bot
    # :nodoc: #
    module Adapter
      # :nodoc: #
      # Wraps a debugging message inside a class.
      class TelegramMessage < Kybus::Bot::Message
        # It receives a string with the raw text and the id of the channel
        def initialize(message)
          super()
          @message = message
        end

        def reply?
          !!@message.reply_to_message
        end

        def replied_message
          TelegramMessage.new(@message.reply_to_message)
        end

        # Returns the channel id
        def channel_id
          @message.chat.id
        end

        # Returns the message contents
        def raw_message
          @message.to_s
        end

        def is_private?
          @message.chat.type == 'private'
        end

        def has_attachment?
          !!@message.document
        end

        def attachment
          @message.document
        end

        def user
          @message.from.id
        end
      end

      class TelegramFile
        extend Kybus::DRY::ResourceInjector
        attr_reader :id

        def initialize(message)
          @id = case message
                when String
                  message
                when Hash
                  message['id'] || message[:id]
                when TelegramFile
                  message.id
                else
                  message.file_id
                end
        end

        def to_h
          {
            provide: 'telegram',
            id: @id
          }
        end

        def cli
          @cli ||= TelegramFile.resource(:cli)
        end

        def meta
          @meta ||= cli.api.get_file(file_id: @id)
        end

        def original_name
          meta.dig('result', 'file_name')
        end

        def download
          token = cli.api.token
          file_path = meta.dig('result', 'file_path')
          path = "https://api.telegram.org/file/bot#{token}/#{file_path}"
          Faraday.get(path).body
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
          TelegramFile.register(:cli, @client)
        end

        # Interface for receiving message
        def read_message
          # take the first message from the first open message,
          loop do
            @client.listen do |message|
              log_info('Received message', message: message.to_h,
                                           from: message.from.to_h)
              return TelegramMessage.new(message)
            end
          rescue ::Telegram::Bot::Exceptions::ResponseError => e
            log_error('An error ocurred while calling to Telegram API', e)
          end
        end

        def mention(id)
          "[user](tg://user?id=#{id})"
        end

        # interface for sending messages
        def send_message(channel_name, contents)
          puts "#{channel_name} => #{contents}" if @config['debug']
          @client.api.send_message(chat_id: channel_name, text: contents)
        rescue ::Telegram::Bot::Exceptions::ResponseError => e
          return if e[:error_code] == '403'
        end

        # interface for sending video
        def send_video(channel_name, video_url)
          file = Faraday::FilePart.new(video_url, 'video/mp4')
          @client.api.send_video(chat_id: channel_name, audio: file)
        end

        # interface for sending uadio
        def send_audio(channel_name, audio_url)
          file = Faraday::FilePart.new(audio_url, 'audio/mp3')
          @client.api.send_audio(chat_id: channel_name, audio: file)
        end

        # interface for sending image
        def send_image(channel_name, image_url)
          file = Faraday::FilePart.new(image_url, 'image/jpeg')
          @client.api.send_photo(chat_id: channel_name, photo: file)
        end

        # interface for sending document
        def send_document(channel_name, image_url)
          file = Faraday::FilePart.new(image_url, 'application/octect-stream')
          @client.api.send_document(chat_id: channel_name, document: file)
        end

        def file_builder(file)
          TelegramFile.new(file)
        end
      end

      register('telegram', Telegram)
    end
  end
end
