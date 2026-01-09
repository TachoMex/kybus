# frozen_string_literal: true

module Kybus
  module Bot
    # Persisted state for a channel (command, params, files, metadata).
    class CommandState
      attr_reader :command

      def initialize(data, command)
        @command = command
        @data = parse_data(data)
      end

      def self.from_json(str, commands_provider)
        data = JSON.parse(str, symbolize_names: true)
        new(data[:data], commands_provider.command(data[:command]))
      end

      def to_json(*_args)
        to_h.to_json
      end

      def to_h
        { command: command&.name, data: @data.to_h.merge(last_message: @data[:last_message]&.to_h) }
      end

      def clear_command
        @data[:cmd] = nil
      end

      def ready?
        command&.ready?(params)
      end

      def next_missing_param
        command.next_missing_param(params)
      end

      # Store the last message for reply context.
      def last_message=(msg)
        @data[:last_message] = msg
      end

      def last_message
        if @data[:last_message].is_a?(String)
          @data[:last_message] =
            SerializedMessage.from_json(parse_json(@data[:last_message]))
        end
        @data[:last_message]
      end

      def command=(cmd)
        @command = cmd
        @data[:cmd] = cmd.name
        @data[:params] = {}
        @data[:files] = {}
      end

      def params
        @data[:params] || {}
      end

      def channel_id
        @data[:channel_id]
      end

      def files
        @data[:files] || {}
      end

      def save_file(identifier, file)
        files[identifier] = file
        store_param(:"_#{@data[:requested_param]}_filename", file.file_name)
      end

      def requested_param=(param)
        @data[:requested_param] = param
      end

      def requested_param
        @data[:requested_param]
      end

      def store_param(param, value)
        @data[:params][param] = value
      end

      # Metadata hash persisted with the state.
      def metadata
        @data[:metadata] = parse_json(@data[:metadata]) if @data[:metadata].is_a?(String)
        @data[:metadata] || {}
      end

      include Kybus::Logger
      # Persist the current state into the repository.
      def save!
        backup = @data.clone
        serialize_data!
        @data.store
        @data = backup
      end

      private

      def parse_data(data)
        data = JSON.parse(data, symbolize_names: true) if data.is_a?(String)
        %i[params metadata files].each do |key|
          data[key] = parse_json(data[key]) if data[key].is_a?(String)
        end
        data[:last_message] = SerializedMessage.from_json(data[:last_message]) if data[:last_message]
        data
      end

      def parse_json(value)
        JSON.parse(value || '{}', symbolize_names: true)
      end

      def serialize_data!
        %i[params files last_message metadata].each do |param|
          @data[param] = @data[param].to_json unless @data[param].is_a?(String)
        end
      end
    end
  end
end
