# frozen_string_literal: true

module Kybus
  module Bot
    class CommandState
      attr_reader :command

      def initialize(data, command)
        @command = command
        data[:params] = JSON.parse(data[:params] || '{}', symbolize_names: true)
        data[:files] = JSON.parse(data[:files] || '{}', symbolize_names: true)
        @data = data
      end

      def clear_command
        @data[:cmd] = nil
      end

      def ready?
        command&.ready?(params)
      end

      # validates which is the following parameter required
      def next_missing_param
        command.next_missing_param(params)
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
        store_param("_#{@data[:requested_param]}_filename".to_sym, file.file_name)
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

      def save!
        backup = @data.clone
        %i[params files].each do |param|
          @data[param] = @data[param].to_json
        end
        @data.store
        %i[params files].each do |param|
          @data[param] = backup[param]
        end
      end
    end
  end
end
