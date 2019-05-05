# frozen_string_literal: true

require 'ant/dry/daemon'
require 'ant/bot/adapters/base'

module Ant
  module Bot
    # Base implementation for messages from distinct providers
    class Message
      # Converts the messages into a hash
      def to_h
        {
          text: raw_message,
          channel: channel_id
        }
      end

      # Returns true when the received message is a command. Convention states
      # that messages should start with '/' to be considered commands
      def command?
        raw_message.start_with?('/')
      end
    end
  end
end
