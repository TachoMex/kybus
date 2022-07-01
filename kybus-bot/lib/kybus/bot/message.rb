# frozen_string_literal: true

require 'kybus/dry/daemon'
require 'kybus/bot/adapters/base'

module Kybus
  module Bot
    # Base implementation for messages from distinct providers
    class Message
      # Converts the messages into a hash
      # Returns true when the received message is a command. Convention states
      # that messages should start with '/' to be considered commands
      def command?
        command&.start_with?('/')
      end

      def command
        raw_message&.split(' ')&.first
      end
    end
  end
end
