# frozen_string_literal: true

module Ant
  module Bot
    # :nodoc: #
    module Adapter
      # :nodoc: #
      # Wraps a debugging message inside a class.
      class DebugMessage < Ant::Bot::Message
        # It receives a string with the raw text and the id of the channel
        def initialize(text, channel)
          @text = text
          @channel = channel
        end

        # Returns the channel id
        def channel_id
          "debug_message__#{@channel}"
        end

        # Returns the message contents
        def raw_message
          @text
        end
      end

      # This class simulates a message chat with a user.
      class Channel
        # It is build from
        # an array of raw messages, the name of the channel and the config
        # to enable debug messages
        def initialize(messages, name, echo)
          @state = :open
          @pending_messages = messages
          @name = name
          @echo = echo
        end

        # Checks if there are messages open or that has not been answered
        def open?
          @state == :open
        end

        # Checks if there are still messages in the channel
        def empty?
          @pending_messages.empty?
        end

        # returns the next message in the buffer
        def read_message
          @state = :closed
          DebugMessage.new(@pending_messages.shift, @name)
        end

        # receives the answer from the bot
        def answer(message)
          if @echo
            # :nocov: #
            puts "Sending message to channel: #{@name}"
            puts message
            # :nocov: #
          end

          @state = :open
        end
      end

      ##
      # This adapter is intended to be used on unit tests and development.
      class Debug
        # Exception for stoping the loop of messages
        class NoMoreMessageException < Ant::Exceptions::AntError
          def initialize
            super('There are no messages left')
          end
        end

        # It receives a hash with the configurations:
        # - name: the name of the channel
        # - channels a key value, where the key is a name and the value the
        #   list of the messages in the channel.
        # - echo: a flag to enable debug messages.
        def initialize(configs)
          @channels = {}
          configs['channels'].each do |name, messages|
            @channels[name] = Channel.new(messages, name, configs['echo'])
          end
        end

        # Interface for receiving message
        def read_message
          # take the first message from the first open message,
          # then rotate the array
          loop do
            raise NoMoreMessageException if @channels.values.all?(&:empty?)

            msg = @channels.values.find(&:open?)
            return msg.read_message if msg

            # :nocov: #
            sleep(1)
            # :nocov: #
          end
        end

        # interface for sending messages
        def send_message(channel, contents)
          @channels[channel.gsub('debug_message__', '')].answer(contents)
        end

        # interface for sending video
        def send_video(_channel, _video_url)
          raise
        end

        # interface for sending uadio
        def send_audio(_channel, _audio_url)
          raise
        end

        # interface for sending image
        def send_image(_channel, _image_url)
          raise
        end
      end

      register('debug', Debug)
    end
  end
end
