# frozen_string_literal: true

require 'forwardable'
require_relative 'command/command'
require_relative 'command/command_definition'
require_relative 'command/execution_context'
require_relative 'dsl_methods'
require_relative 'command/command_handler'
require_relative 'command/parameter_saver'

module Kybus
  module Bot
    class CommandExecutor
      extend Forwardable

      include Kybus::Logger
      attr_reader :dsl, :bot, :execution_context, :channel_factory, :inline_args, :error

      def_delegator :execution_context, :save!, :save_execution_context!

      def state
        execution_context&.state
      end

      def last_message
        state&.last_message
      end

      def initialize(bot, channel_factory, inline_args)
        @bot = bot
        @channel_factory = channel_factory
        @dsl = DSLMethods.new(bot.provider, state, bot)
        @inline_args = inline_args
        @precommand_hook = proc {}
        @parameter_saver = ParameterSaver.new(self)
        @command_handler = CommandHandler.new(self)
      end

      def precommand_hook(&)
        if block_given?
          @precommand_hook = proc(&)
        else
          @precommand_hook
        end
      end

      def process_message(message)
        load_state!(message.channel_id)
        @parameter_saver.save_token!(message)
        msg = @command_handler.run_command_or_prepare!
        save_execution_context!
        msg
      end

      def fallback(error)
        catch_command = @channel_factory.command(error)
        log_error('Unexpected error', error)
        execution_context.command = catch_command if catch_command
      end

      def run_command!
        execution_context.call!(@dsl)
      rescue StandardError => e
        raise unless fallback(e)

        execution_context.state.store_param(:_last_exception, e)
        retry
      end

      def invoke(command, args)
        set_state_command(command, args)
        @command_handler.run_command_or_prepare!
      end

      def redirect(command_name, args)
        command = @channel_factory.command(command_name)
        validate_redirect(command, command_name, args)
        invoke(command, args)
      end

      def ask_param(param, label = nil)
        msg = label || "I need you to tell me #{param}"
        bot.dsl.send_message(msg, last_message.channel_id)
        execution_context.next_param = param
      end

      def load_state!(channel_id)
        @execution_context = ExecutionContest.new(channel_id, @channel_factory)
        @dsl.state = @execution_context.state
      end

      def save_state!
        @dsl.state.save!
      end

      private

      def set_state_command(command, args)
        state.command = command
        command.params.zip(args).each do |param, value|
          state.store_param(param, value)
        end
      end

      def validate_redirect(command, command_name, args)
        return unless command.nil? || command.params_size != args.size

        raise ::Kybus::Bot::Base::BotError, "Wrong redirect #{command_name}, #{bot.registered_commands}"
      end
    end
  end
end
