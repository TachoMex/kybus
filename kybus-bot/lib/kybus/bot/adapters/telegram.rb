# frozen_string_literal: true

require 'telegram/bot'
require 'timeout'
require 'faraday'
require_relative 'telegram_file'
require_relative 'telegram_message'

module Kybus
  module Bot
    module Adapter
      # Telegram adapter for polling and sending messages.
      class Telegram
        include ::Kybus::Logger

        attr_reader :last_message

        def initialize(configs)
          @config = configs
          @client = ::Telegram::Bot::Client.new(@config['token'])
          TelegramFile.register(:cli, @client)
        end

        # Blocking read from Telegram long-polling.
        def read_message
          loop do
            Timeout.timeout(30) do
              @client.listen do |message|
                if message.respond_to?(:data) && message.respond_to?(:message)
                  return @last_message = serialize_callback_query(message)
                end
                log_info('Received message', message: message.to_h, from: message.from.to_h)
                return @last_message = TelegramMessage.new(message)
              end
            end
          rescue ::Telegram::Bot::Exceptions::ResponseError => e
            log_error('An error occurred while calling to Telegram API', e)
            sleep(5)
          rescue Timeout::Error
            log_error('Telegram read timeout, retrying')
            sleep(2)
          rescue StandardError => e
            log_error('Error while reading Telegram message', error: e.class, msg: e.message)
            sleep(5)
          end
        end

        # Parse a webhook-style payload into a SerializedMessage.
        def handle_message(body)
          if body['callback_query']
            return serialize_callback_payload(body['callback_query'])
          end
          chat_id = body.dig('message', 'chat', 'id')
          message_id = body.dig('message', 'message_id')
          user = extract_user(body.dig('message', 'from'))
          raw_message = body.dig('message', 'text')
          is_private = body.dig('message', 'chat', 'type') == 'private'
          attachment = extract_attachment(body['message'])
          serialized_replied_message = serialize_replied_message(body.dig('message', 'reply_to_message'))

          SerializedMessage.new(provider: 'telegram', channel_id: chat_id, message_id:, user:,
                                replied_message: serialized_replied_message, raw_message:, is_private?: is_private,
                                attachment:)
        end

        def mention(id)
          "[user](tg://user?id=#{id})"
        end

        # Send a text message.
        def send_message(contents, channel_name)
          log_debug('Sending message', channel_name:, message: contents)
          @client.api.send_message(chat_id: channel_name.to_i, text: contents, parse_mode: @config['parse_mode'])
        rescue ::Telegram::Bot::Exceptions::ResponseError => e
          nil if e.error_code == '403'
        end

        # Send a text message with reply markup.
        def send_message_with_markup(contents, channel_name, reply_markup: nil)
          log_debug('Sending message', channel_name:, message: contents)
          @client.api.send_message(chat_id: channel_name.to_i, text: contents, parse_mode: @config['parse_mode'],
                                   reply_markup: reply_markup)
        rescue ::Telegram::Bot::Exceptions::ResponseError => e
          nil if e.error_code == '403'
        end

        # Edit an existing message.
        def edit_message_text(channel_name, message_id, contents, reply_markup: nil)
          @client.api.edit_message_text(chat_id: channel_name.to_i, message_id: message_id, text: contents,
                                        parse_mode: @config['parse_mode'], reply_markup: reply_markup)
        rescue ::Telegram::Bot::Exceptions::ResponseError => e
          nil if e.error_code == '403'
        end

        def send_video(channel_name, video_url, comment = nil)
          file = Faraday::FilePart.new(video_url, 'video/mp4')
          @client.api.send_video(chat_id: channel_name, video: file, caption: comment, parse_mode: @config['parse_mode'])
        rescue ::Telegram::Bot::Exceptions::ResponseError => e
          nil if e.error_code == '403'
        end

        def send_audio(channel_name, audio_url, comment = nil)
          file = Faraday::FilePart.new(audio_url, 'audio/mp3')
          @client.api.send_audio(chat_id: channel_name, audio: file, caption: comment, parse_mode: @config['parse_mode'])
        rescue ::Telegram::Bot::Exceptions::ResponseError => e
          nil if e.error_code == '403'
        end

        def send_image(channel_name, image_url, comment = nil)
          file = Faraday::FilePart.new(image_url, 'image/jpeg')
          @client.api.send_photo(chat_id: channel_name, photo: file, caption: comment, parse_mode: @config['parse_mode'])
        rescue ::Telegram::Bot::Exceptions::ResponseError => e
          nil if e.error_code == '403'
        end

        def send_document(channel_name, image_url, comment = nil)
          file = Faraday::FilePart.new(image_url, 'application/octet-stream')
          @client.api.send_document(chat_id: channel_name, document: file, caption: comment, parse_mode: @config['parse_mode'])
        rescue ::Telegram::Bot::Exceptions::ResponseError => e
          nil if e.error_code == '403'
        end

        def message_builder(raw_message)
          TelegramMessage.new(raw_message)
        end

        def file_builder(file)
          TelegramFile.new(file)
        end

        private

        def extract_user(from)
          return if from.nil?

          if from.respond_to?(:username) || from.respond_to?(:first_name)
            username = from.respond_to?(:username) ? from.username : nil
            return username if username && !username.to_s.empty?

            return from.first_name if from.respond_to?(:first_name)
          end

          return from[:username] || from[:first_name] if from.respond_to?(:[])

          nil
        end

        def extract_attachment(message)
          return unless message

          %w[photo document video].each do |type|
            attachment = message[type]
            return type == 'photo' ? attachment.last : attachment if attachment
          end
          nil
        end

        def serialize_replied_message(replied_message)
          return unless replied_message

          SerializedMessage.new(
            provider: 'telegram',
            channel_id: replied_message.dig('chat', 'id'),
            message_id: replied_message['message_id'],
            user: extract_user(replied_message['from']),
            raw_message: replied_message['text'],
            is_private?: replied_message.dig('chat', 'type') == 'private'
          ).serialize
        end

        def serialize_callback_query(callback)
          msg = callback.message
          SerializedMessage.new(
            provider: 'telegram',
            channel_id: msg.chat.id,
            message_id: msg.message_id,
            user: extract_user(callback.from),
            replied_message: nil,
            raw_message: callback.data,
            is_private?: msg.chat.type == 'private',
            callback: true,
            attachment: nil
          )
        end

        def serialize_callback_payload(callback)
          msg = callback['message'] || {}
          chat = msg['chat'] || {}
          SerializedMessage.new(
            provider: 'telegram',
            channel_id: chat['id'],
            message_id: msg['message_id'],
            user: extract_user(callback['from'] || {}),
            replied_message: nil,
            raw_message: callback['data'],
            is_private?: chat['type'] == 'private',
            callback: true,
            attachment: nil
          )
        end
      end

      register('telegram', Telegram)
    end
  end
end
