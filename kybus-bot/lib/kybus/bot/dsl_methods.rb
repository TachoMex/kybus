# frozen_string_literal: true

module Kybus
  module Bot
    class DSLMethods
      attr_accessor :state
      attr_reader :provider

      def initialize(provider, state)
        @provider = provider
        @state = state
      end

      # returns the current_channel from where the message was sent
      def current_channel
        state.channel_id
      end

      def send_message(content, channel = nil)
        raise(Base::EmptyMessageError) unless content

        provider.send_message(channel || current_channel, content)
      end

      def send_image(content, channel = nil)
        provider.send_image(channel || current_channel, content)
      end

      def send_audio(content, channel = nil)
        provider.send_audio(channel || current_channel, content)
      end

      def send_document(content, channel = nil)
        provider.send_document(channel || current_channel, content)
      end

      def params
        state.params
      end

      def files
        state.files
      end

      def file(name)
        (file = files[name]) && provider.file_builder(file)
      end

      def mention(name)
        provider.mention(name)
      end

      def current_user
        state.last_message.user
      end

      def is_private?
        state.last_message.is_private?
      end
    end
  end
end
