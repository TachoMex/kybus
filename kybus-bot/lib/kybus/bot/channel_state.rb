# frozen_string_literal: true

module Kybus
  module Bot
    class ChannelState
      extend Kybus::DRY::ResourceInjector

      attr_accessor :last_message

      def self.factory
        resource(:factory)
      end

      def self.load_state(channel)
        data = factory.get(channel)
        new(data)
      rescue Kybus::Storage::Exceptions::ObjectNotFound
        new(factory.create(channel_id: channel, params: '{}'))
      end

      def initialize(data)
        data[:params] = JSON.parse(data[:params] || '{}', symbolize_names: true)
        data[:files] = JSON.parse(data[:files] || '{}', symbolize_names: true)
        @data = data
      end

      def clear_command
        @data[:cmd] = nil
      end

      def command=(cmd)
        @data[:cmd] = cmd.split.first
        @data[:params] = {}
        @data[:files] = {}
      end

      def command
        @data[:cmd]
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

      def to_h
        @data.to_h
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
