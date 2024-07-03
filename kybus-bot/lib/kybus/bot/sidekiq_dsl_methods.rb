# frozen_string_literal: true

module Kybus
  module Bot
    class SidekiqDSLMethods < DSLMethods
      def initialize(provider, state, bot, factory)
        super(provider, state, bot)
        @factory = factory
      end

      def redirect(command_name, args = {})
        command = @factory.command(command_name)
        raise "Wrong redirect #{command_name}" if command.nil? || command.params_size != args.size

        state.command = command
        command.params.zip(args).each do |param, value|
          state.store_param(param, value)
        end

        instance_eval(&state.command.block)
      end
    end
  end
end
