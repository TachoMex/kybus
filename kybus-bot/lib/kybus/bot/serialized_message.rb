# frozen_string_literal: true

module Kybus
  module Bot
    # Base iplementation for messages from distinct providers
    class SerializedMessage < Message
      MANDATORY_FIELDS = %i[channel_id provider message_id user raw_message].freeze

      def initialize(data)
        missing_keys = MANDATORY_FIELDS.reject { |k| data.keys.include?(k) }
        raise "BadSerializedMessage: Missing keys `#{missing_keys}', got: #{data}" unless missing_keys.empty?

        @data = data.is_a?(String) ? JSON.parse(data, symbolize_names: true) : data
        @data[:replied_message] = SerializedMessage.new(@data[:replied_message]) if @data[:replied_message]
      end

      def self.from_json(json)
        data = json.is_a?(String) ? JSON.parse(json, symbolize_names: true) : json
        new(data)
      end

      def reply?
        @data[:replied_message].is_a?(SerializedMessage)
      end

      def has_attachment?
        !@data[attachment].nil?
      end

      def method_missing(method, *_args)
        @data[method]
      end

      def to_h
        @data.dup
      end

      def to_json(*args)
        @data.to_json(*args)
      end
    end
  end
end
