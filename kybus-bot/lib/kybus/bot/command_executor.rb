# frozen_string_literal: true

require 'forwardable'
require_relative 'command/command'
require_relative 'command/command_definition'
require_relative 'command/execution_context'

module Kybus
  module Bot
    class CommandExecutor
      extend Forwardable

      include Kybus::Logger
      attr_reader :dsl, :bot, :execution_context

      def_delegator :execution_context, :save!, :save_execution_context!

      def state
        execution_context&.state
      end

      def initialize(bot, channel_factory, inline_args)
        @bot = bot
        @channel_factory = channel_factory
        @dsl = DSLMethods.new(bot.provider, state, bot)
        @inline_args = inline_args
        @precommand_hook = proc {}
      end

      # Process a single message, this method can be overwriten to enable
      # more complex implementations of commands. It receives a message object.
      def process_message(message)
        @execution_context = ExecutionContest.new(message.channel_id, @channel_factory)
        save_token!(message)
        msg = run_command_or_prepare!
        save_execution_context!
        msg
      end

      def save_param!(message)
        execution_context.add_param(message.raw_message)
        return unless message.has_attachment?

        file = bot.provider.file_builder(message.attachment)
        execution_context.add_file(file)
      end

      def search_command_with_inline_arg(message)
        command, values = @channel_factory.command_with_inline_arg(message.raw_message)
        if command
          execution_context.command = command
          values.each do |value|
            execution_context.next_param = execution_context.next_missing_param
            execution_context.add_param(value)
          end
        else
          execution_context.command = @channel_factory.default_command
        end
      end

      def save_token!(message)
        if execution_context.expecting_command?
          command = @channel_factory.command(message.command)
          if @inline_args && !command
            search_command_with_inline_arg(message)
          elsif !@inline_args && !command
            execution_context.command = @channel_factory.default_command
          else
            execution_context.command = command
          end
        else
          save_param!(message)
        end
      end

      def run_command_or_prepare!
        if execution_context.ready?
          @dsl.state = execution_context.state
          @dsl.instance_eval(&@precommand_hook)
          msg = run_command!
          execution_context.clear_command
          msg
        else
          param = execution_context.next_missing_param
          ask_param(param, execution_context.state.command.params_ask_label(param))
        end
      end

      def precommand_hook(&block)
        @precommand_hook = proc(&block)
      end

      def fallback(error)
        catch = @channel_factory.command(error)
        log_error('Unexpected error', error)
        execution_context.command = catch if catch
      end

      # Method for triggering command
      def run_command!
        execution_context.call!(@dsl)
      rescue StandardError => e
        raise unless fallback(e)

        execution_context.state.store_param(:_last_exception, e)
        retry
      end

      def invoke(command_name, args)
        command = @channel_factory.command(command_name)
        if command.nil? || command.params_size != args.size
          raise "Wrong redirect #{command_name}, #{bot.registered_commands}"
        end

        state.command = command
        command.params.zip(args).each do |param, value|
          state.store_param(param, value)
        end
        run_command_or_prepare!
      end

      # Sends a message to get the next parameter from the user
      def ask_param(param, label = nil)
        provider = bot.provider
        msg = label || "I need you to tell me #{param}"
        bot.send_message(provider.last_message.channel_id, msg)
        execution_context.next_param = param
      end
    end
  end
end
