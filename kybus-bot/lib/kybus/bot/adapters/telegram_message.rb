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
          @message.respond_to?(:reply_to_message) && @message.reply_to_message
        end

        def replied_message
          TelegramMessage.new(@message.reply_to_message)
        end

        # Returns the channel id
        def channel_id
          @message.chat.id
        end

        def message_id
          @message.respond_to?(:message_id) ? @message.message_id : @message['result']['message_id']
        end

        # Returns the message contents
        def raw_message
          @message.to_s
        end

        def is_private?
          @message.chat.type == 'private'
        end

        def has_attachment?
          !!attachment
        end

        def attachment
          (@message.respond_to?(:document) && @message.document) || 
            (@message.respond_to?(:photo) && @message.photo&.last) || 
            (@message.respond_to?(:audio) && @message&.audio)
        end

        def user
          @message.from.id
        end
      end
    end
  end
end
