# frozen_string_literal: true

require_relative 'base'
require_relative '../message'

module Kybus
  module Bot
    # :nodoc: #
    module Adapter
      # :nodoc: #
      # Wraps a debugging message inside a class.
      class DebugMessage < Kybus::Bot::Message
        # It receives a string with the raw text and the id of the channel
        attr_reader :attachment

        def initialize(text, channel, attachment = nil)
          super()
          @text = text
          @channel = channel
          @attachment = attachment
        end

        # Returns the channel id
        def channel_id
          "debug_message__#{@channel}"
        end

        # Returns the message contents
        def raw_message
          @text
        end

        def user
          channel_id
        end

        def has_attachment?
          !!attachment
        end
      end

      # This class simulates a message chat with a user.
      class Channel
        # It is build from
        # an array of raw messages, the name of the channel and the config
        # to enable debug messages
        def initialize(messages, name, echo)
          @state = :open
          @pending_messages = messages.dup
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

        def send_data(message, _attachment)
          return unless @echo

          puts "Sending message to channel: #{@name}"
          puts message
        end

        attr_writer :echo

        # receives the answer from the bot
        def answer(message, attachment = nil)
          send_data(message, attachment)
          @state = :open
        end
      end

      ##
      # This adapter is intended to be used on unit tests and development.
      class Debug
        # Exception for stoping the loop of messages
        class NoMoreMessageException < Kybus::Exceptions::AntError
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

        # removes prefix from channel id
        def channel(name)
          @channels[name.gsub('debug_message__', '')]
        end

        # interface for sending messages
        def send_message(channel_name, contents, attachment = nil)
          channel(channel_name).answer(contents, attachment)
        end

        # interface for sending video
        def send_video(channel_name, video_url)
          channel(channel_name).answer("VIDEO: #{video_url}")
        end

        # interface for sending uadio
        def send_audio(channel_name, audio_url)
          channel(channel_name).answer("AUDIO: #{audio_url}")
        end

        # interface for sending image
        def send_image(channel_name, image_url)
          channel(channel_name).answer("IMG: #{image_url}")
        end

        # changes echo config
        def echo=(toogle)
          @channels.each { |_, channel| channel.echo = toogle }
        end
      end

      register('debug', Debug)
    end
  end
end
