# frozen_string_literal: true

require 'discordrb'

module Kybus
  module Bot
    # :nodoc: #
    module Adapter
      # :nodoc: #
      # Wraps a debugging message inside a class.
      class DiscordMessage < Kybus::Bot::Message
        # It receives a string with the raw text and the id of the channel
        def initialize(msg)
          @message = msg
        end

        # Returns the channel id
        def channel_id
          @message.channel.id
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
          @message.message.reply?
        end

        def replied_message
          DiscordMessage.new(@message.message.referenced_message)
        end
      end

      ##
      # This adapter is intended to be used on unit tests and development.
      class Discord
        include ::Kybus::Logger
        # It receives a hash with the configurations:
        # - name: the name of the channel
        # - channels a key value, where the key is a name and the value the
        #   list of the messages in the channel.
        # - echo: a flag to enable debug messages.
        def initialize(configs)
          @config = configs
          @client = Discordrb::Bot.new(token: @config['token'])
          @pool = []
          @client.message do |msg|
            @pool << msg
          end
          @client.run(:async)
        end

        attr_reader :client

        def mention(id)
          "<@!#{id}>"
        end

        # Interface for receiving message
        def read_message
          # take the first message from the first open message,
          loop do
            if @pool.empty?
              sleep(0.1)
            else
              break
            end
          end
          DiscordMessage.new(@pool.shift)
        end

        # interface for sending messages
        def send_message(channel_name, contents)
          puts "#{channel_name} => #{contents}" if @config['debug']
          channel = @client.channel(channel_name)
          if channel
            channel.send_message(contents)
          else
            @client.user(channel_name).pm(contents)
          end
        end

        # # interface for sending video
        # def send_video(channel_name, video_url)
        #   file = Faraday::UploadIO.new(video_url, 'video/mp4')
        #   @client.api.send_video(chat_id: channel_name, audio: file)
        # end
        #
        # # interface for sending uadio
        # def send_audio(channel_name, audio_url)
        #   file = Faraday::UploadIO.new(audio_url, 'audio/mp3')
        #   @client.api.send_audio(chat_id: channel_name, audio: file)
        # end
        #
        # # interface for sending image
        # def send_image(channel_name, image_url)
        #   file = Faraday::UploadIO.new(image_url, 'image/jpeg')
        #   @client.api.send_photo(chat_id: channel_name, photo: file)
        # end
      end

      register('discord', Discord)
    end
  end
end
