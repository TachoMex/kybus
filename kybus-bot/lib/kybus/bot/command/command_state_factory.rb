# frozen_string_literal: true

require_relative 'regular_command_matcher'
require_relative 'inline_command_matcher'

module Kybus
  module Bot
    class CommandStateFactory
      include Kybus::Storage::Datasource
      attr_reader :factory

      def initialize(repository, definitions)
        @factory = build_factory(repository)
        @definitions = definitions
        @regular_command_matcher = RegularCommandMatcher.new(definitions)
        @inline_command_matcher = InlineCommandMatcher.new(definitions)
      end

      def command(search)
        @regular_command_matcher.find_command(search)
      end

      def default_command
        @definitions['default']
      end

      def command_or_default(name)
        command(name) || default_command
      end

      def command_with_inline_arg(name_with_arg)
        @inline_command_matcher.find_command_with_inline_arg(name_with_arg)
      end

      def load_state(channel)
        data = factory.get(channel.to_s)
        CommandState.new(data, command(data[:cmd]))
      rescue Kybus::Storage::Exceptions::ObjectNotFound
        CommandState.new(factory.create(channel_id: channel.to_s, params: '{}', metadata: '{}', last_message: nil), nil)
      end

      private

      def build_factory(repository)
        factory = Kybus::Storage::Factory.new(EmptyModel)
        factory.register(:default, :json)
        factory.register(:json, repository)
        factory
      end
    end
  end
end
