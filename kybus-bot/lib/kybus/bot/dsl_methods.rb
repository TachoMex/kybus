# frozen_string_literal: true

module Kybus
  module Bot
    # DSL available inside command blocks (send, read params, redirect, etc).
    class DSLMethods
      include Kybus::Logger

      attr_accessor :state
      attr_reader :provider, :args

      def initialize(provider, state, bot)
        @provider = provider
        @state = state
        @bot = bot
      end

      # Send a text message to a channel.
      def send_message(content, channel = nil)
        raise(Base::EmptyMessageError) unless content

        @bot.send_message(content, channel || current_channel)
      end

      # Send an image with optional caption.
      def send_image(content, channel = nil, caption: nil)
        provider.send_image(channel || current_channel, content, caption)
      end

      # Send a video with optional caption.
      def send_video(content, channel = nil, caption: nil)
        provider.send_video(channel || current_channel, content, caption)
      end

      # Send an audio file with optional caption.
      def send_audio(content, channel = nil, caption: nil)
        provider.send_audio(channel || current_channel, content, caption)
      end

      # Send a document with optional caption.
      def send_document(content, channel = nil, caption: nil)
        provider.send_document(channel || current_channel, content, caption)
      end

      # Parsed params for the current command.
      def params
        state.params
      end

      # Uploaded files for the current command.
      def files
        state.files
      end

      # Persisted metadata for the current channel.
      def metadata
        state.metadata
      end

      # Fetch a file builder for an uploaded file.
      def file(name)
        (file = files[name]) && provider.file_builder(file)
      end

      # Build a provider-specific mention.
      def mention(name)
        provider.mention(name)
      end

      # Current user identifier from the provider.
      def current_user
        last_message.user
      end

      # True if the current message is private.
      def is_private?
        last_message.is_private?
      end

      def last_message
        state.last_message
      end

      # returns the current_channel from where the message was sent
      # Channel identifier for the current message.
      def current_channel
        last_message.channel_id
      end

      # Current command name, if any.
      def command_name
        state&.command&.name
      end

      # Persist metadata to the state repository.
      def save_metadata!
        state.save!
      end

      # Access the owning bot instance.
      def bot
        @bot
      end

      # Redirect to another command.
      def redirect(*)
        @bot.redirect(*)
      end

      # Abort execution with optional message.
      def abort(msg = nil)
        raise ::Kybus::Bot::Base::AbortError, msg
      end

      # Enqueue a job for background execution.
      def fork(command, arguments = {})
        @bot.invoke_job(command, arguments)
      end

      # Enqueue a job after a delay.
      def fork_with_delay(command, delay, arguments = {})
        @bot.invoke_job_with_delay(command, delay, arguments)
      end
    end
  end
end
