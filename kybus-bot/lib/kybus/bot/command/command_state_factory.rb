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

      def command_or_default(name)
        command(name) || @definitions['default']
      end

      def load_state(channel)
        data = factory.get(channel)
        CommandState.new(data, command_or_default(data[:cmd]))
      rescue Kybus::Storage::Exceptions::ObjectNotFound
        CommandState.new(factory.create(channel_id: channel, params: '{}'), nil)
      end
    end
  end
end
