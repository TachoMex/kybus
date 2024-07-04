# frozen_string_literal: true

module Kybus
  module Bot
    # Base implementation for messages from distinct providers
    class SerializedMessage < Message
      MANDATORY_FIELDS = %i[channel_id provider message_id user raw_message].freeze

      def initialize(data)
        super()
        @data = parse_data(data)
        validate_data!
        parse_replied_message
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

      def method_missing(method, *_args) # rubocop:disable Style/MissingRespondToMissing
        @data[method]
      end

      def to_h
        @data.dup
      end

      def to_json(*)
        @data.to_json(*)
      end

      private

      def parse_data(data)
        data = data.to_h if data.is_a?(SerializedMessage)
        raise Base::BotError, 'BadSerializedMessage: nil message' if data.nil?

        data = data[:data] if data.is_a?(Hash) && data.key?(:data)
        data.is_a?(String) ? JSON.parse(data, symbolize_names: true) : data
      end

      def validate_data!
        missing_keys = MANDATORY_FIELDS.reject { |k| @data.key?(k) }
        return if missing_keys.empty?

        raise Base::BotError,
              "BadSerializedMessage: Missing keys `#{missing_keys}', got: #{@data}"
      end

      def parse_replied_message
        return unless @data[:replied_message]

        @data[:replied_message] = SerializedMessage.new(@data[:replied_message])
      end
    end
  end
end
