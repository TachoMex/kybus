# frozen_string_literal: true

require 'telegram/bot'
require 'faraday'

module Kybus
  module Bot
    # :nodoc: #
    module Adapter
      class TelegramFile
        extend Kybus::DRY::ResourceInjector
        attr_reader :id

        def initialize(message)
          @id = case message
                when String
                  message
                when Hash
                  message['id'] || message[:id]
                when TelegramFile
                  message.id
                else
                  message.file_id
                end
        end

        def to_h
          {
            provide: 'telegram',
            id: @id
          }
        end

        def cli
          @cli ||= TelegramFile.resource(:cli)
        end

        def meta
          @meta ||= cli.api.get_file(file_id: @id)
        end

        def original_name
          meta.dig('result', 'file_name')
        end

        def download
          token = cli.api.token
          file_path = meta.dig('result', 'file_path')
          path = "https://api.telegram.org/file/bot#{token}/#{file_path}"
          Faraday.get(path).body
        end
      end
    end
  end
end
