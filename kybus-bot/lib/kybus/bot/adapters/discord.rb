# frozen_string_literal: true

require 'discordrb'

module Kybus
  module Bot
    # :nodoc: #
    module Adapter
      # :nodoc: #
      # Wraps a Discord message and exposes Kybus::Bot::Message API.
      class DiscordMessage < Kybus::Bot::Message
        # It receives a string with the raw text and the id of the channel
        def initialize(msg)
          super()
          @message = msg
        end

        # Returns the channel id
        def channel_id
          @message.channel.id
        end

        def message_id
          @message.id if @message.respond_to?(:id)
        end

        def has_attachment?
          !!attachment
        end

        def attachment
          @message.file
        end

        # Returns the message contents
        def raw_message
          @message.content
        end

        def user
          @message.author.id
        end

        def is_private?
          @message.channel.private?
        end

        def reply?
          return false unless @message.respond_to?(:referenced_message)

          !@message.referenced_message.nil?
        end

        def replied_message
          return unless reply?

          DiscordMessage.new(@message.referenced_message)
        end
      end

      ##
      # Discord adapter for polling and sending messages.
      class Discord
        include ::Kybus::Logger

        attr_reader :last_message, :client

        # It receives a hash with the configurations:
        # - name: the name of the channel
        # - channels a key value, where the key is a name and the value the
        #   list of the messages in the channel.
        # - echo: a flag to enable debug messages.
        def initialize(configs)
          @config = configs
          @client = Discordrb::Bot.new(token: @config['token'])
          @pool = Queue.new
          @client.message do |msg|
            @pool << msg
          end
          @client.run(:async)
        end

        def mention(id)
          "<@!#{id}>"
        end

        # Interface for receiving message
        def read_message
          loop do
            begin
              msg = @pool.pop(true)
              return @last_message = DiscordMessage.new(msg)
            rescue ThreadError
              sleep(0.1)
            end
          end
        end

        # interface for sending messages
        def send_message(contents, channel_name, _caption = nil)
          puts "#{channel_name} => #{contents}" if @config['debug']
          channel = @client.channel(channel_name)
          if channel
            channel.send_message(contents)
          else
            @client.user(channel_name).pm(contents)
          end
        rescue StandardError => e
          log_error('Discord send_message failed', error: e.class, msg: e.message)
        end

        def message_builder(raw_message)
          DiscordMessage.new(raw_message)
        end

        def send_file(channel_name, file, _caption = nil)
          @client.send_file(channel_name, File.open(file, 'r'))
        rescue StandardError => e
          log_error('Discord send_file failed', error: e.class, msg: e.message)
        end

        def send_video(channel_name, file, _caption = nil)
          @client.send_file(channel_name, File.open(file, 'r'))
        rescue StandardError => e
          log_error('Discord send_video failed', error: e.class, msg: e.message)
        end

        # interface for sending uadio
        def send_audio(channel_name, file, _caption = nil)
          @client.send_file(channel_name, File.open(file, 'r'))
        rescue StandardError => e
          log_error('Discord send_audio failed', error: e.class, msg: e.message)
        end

        # interface for sending image
        def send_image(channel_name, file, _caption = nil)
          @client.send_file(channel_name, File.open(file, 'r'))
        rescue StandardError => e
          log_error('Discord send_image failed', error: e.class, msg: e.message)
        end

        def send_document(channel_name, file, _caption = nil)
          @client.send_file(channel_name, File.open(file, 'r'))
        rescue StandardError => e
          log_error('Discord send_document failed', error: e.class, msg: e.message)
        end
      end

      register('discord', Discord)
    end
  end
end
