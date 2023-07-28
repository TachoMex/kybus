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

      def command(search)
        @definitions.each do |name, command|
          case name
          when String
            return command if name == search
          when Class
            return command if search.is_a?(name)
          when Regexp
            if search.is_a?(String) && name.match?(search)
              storable_command = command.clone
              storable_command.name = search
              return storable_command
            end
          end
        end
        nil
      end

      def default_command
        @definitions['default']
      end

      def command_or_default(name)
        command(name) || default_command
      end

      def command_with_inline_arg(name_with_arg)
        @definitions.each do |name, command|
          case name
          when Class
            return [command, []] if name_with_arg.is_a?(name)
          when String
            return [command, name_with_arg.gsub(name, '').split('__')] if name_with_arg.start_with?(name)
          when Regexp
            next unless name_with_arg.match?(name)

            storable_command = command.dup
            storable_command.name = name_with_arg
            return [storable_command, [name_with_arg]]
          end
        end
        nil
      end

      def load_state(channel)
        data = factory.get(channel.to_s)
        CommandState.new(data, command(data[:cmd]))
      rescue Kybus::Storage::Exceptions::ObjectNotFound
        CommandState.new(factory.create(channel_id: channel.to_s, params: '{}', last_message: nil), nil)
      end
    end
  end
end
