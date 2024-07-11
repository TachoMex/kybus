# frozen_string_literal: true

module Kybus
  module Bot
    class DSLMethods
      include Kybus::Logger

      attr_accessor :state
      attr_reader :provider, :args

      def initialize(provider, state, bot)
        @provider = provider
        @state = state
        @bot = bot
      end

      def send_message(content, channel = nil)
        raise(Base::EmptyMessageError) unless content

        @bot.send_message(content, channel || current_channel)
      end

      def send_image(content, channel = nil, caption: nil)
        provider.send_image(channel || current_channel, content, caption)
      end

      def send_video(content, channel = nil, caption: nil)
        provider.send_video(channel || current_channel, content, caption)
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

      def metadata
        state.metadata
      end

      def file(name)
        (file = files[name]) && provider.file_builder(file)
      end

      def mention(name)
        provider.mention(name)
      end

      def current_user
        last_message.user
      end

      def is_private?
        last_message.is_private?
      end

      def last_message
        state.last_message
      end

      # returns the current_channel from where the message was sent
      def current_channel
        last_message.channel_id
      end

      def command_name
        state&.command&.name
      end

      def save_metadata!
        state.save!
      end

      def redirect(*)
        @bot.redirect(*)
      end

      def abort(msg = nil)
        raise ::Kybus::Bot::Base::AbortError, msg
      end

      def fork(command, arguments = {})
        @bot.invoke_job(command, arguments)
      end

      def fork_with_delay(command, delay, arguments = {})
        @bot.invoke_job_with_delay(command, delay, arguments)
      end
    end
  end
end
