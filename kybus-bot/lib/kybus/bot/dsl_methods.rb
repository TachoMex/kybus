# frozen_string_literal: true

module Kybus
  module Bot
    module DSLMethods
      def send_message(content, channel = nil)
        raise(EmptyMessageError) unless content

        provider.send_message(channel || current_channel, content)
      end

      def rescue_from(klass, &block)
        @commands.register_command(klass, [], block)
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

      # DSL method for adding simple commands
      def register_command(name, params = [], &block)
        @commands.register_command(name, params, block)
      end

      # loads parameters from state
      def current_params
        @state.params
      end

      def params
        current_params
      end

      def files
        @state.files
      end

      def file(name)
        (file = files[name]) && provider.file_builder(file)
      end

      def mention(name)
        provider.mention(name)
      end

      # returns the current_channel from where the message was sent
      def current_channel
        @state.channel_id
      end

      def current_user
        @last_message.user
      end

      def is_private?
        @last_message.is_private?
      end
    end
  end
end
