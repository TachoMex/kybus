# frozen_string_literal: true

module Kybus
  module Bot
    class CommandStateFactory
      include Kybus::Storage::Datasource
      attr_reader :factory

      def initialize(repository, definitions)
        factory = Kybus::Storage::Factory.new(EmptyModel)
        factory.register(:default, :json)
        factory.register(:json, repository)
        @factory = factory
        @definitions = definitions
      end

      def command(name)
        @definitions[name]
      end

      def default_command
        @definitions['default']
      end

      def command_or_default(name)
        command(name) || default_command
      end

      def command_with_inline_arg(name_with_arg)
        @definitions.each do |name, command|
          next unless name.is_a?(String)
          return [command, name_with_arg.gsub(name, '').split('__')] if name_with_arg.start_with?(name)
        end
        nil
      end

      def load_state(channel)
        data = factory.get(channel.to_s)
        CommandState.new(data, command_or_default(data[:cmd]))
      rescue Kybus::Storage::Exceptions::ObjectNotFound
        CommandState.new(factory.create(channel_id: channel.to_s, params: '{}'), nil)
      end
    end
  end
end
