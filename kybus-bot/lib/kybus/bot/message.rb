# frozen_string_literal: true

require 'kybus/dry/daemon'
require 'kybus/bot/adapters/base'

module Kybus
  module Bot
    # Base implementation for messages from distinct providers
    class Message
      require_relative 'serialized_message'
      # Converts the messages into a hash
      # Returns true when the received message is a command. Convention states
      # that messages should start with '/' to be considered commands
      def command?
        command&.start_with?('/')
      end

      def command
        raw_message&.split(' ')&.first
      end

      def serialize
        SerializedMessage.new({
                                provider: self.class.name,
                                channel_id:,
                                message_id:,
                                user:,
                                replied_message: reply? ? replied_message.serialize : nil,
                                raw_message:,
                                is_private?: is_private?,
                                attachment: has_attachment? ? attachment : nil
                              })
      end
    end
  end
end
