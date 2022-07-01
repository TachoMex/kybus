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

      def initialize(bot, channel_factory)
        @bot = bot
        @channel_factory = channel_factory
        @dsl = DSLMethods.new(bot.provider, state)
      end

      # Process a single message, this method can be overwriten to enable
      # more complex implementations of commands. It receives a message object.
      def process_message(message)
        @execution_context = ExecutionContest.new(message.channel_id, @channel_factory)
        save_token!(message)
        run_command_or_prepare!
        save_execution_context!
      end

      def save_param!(message)
        execution_context.add_param(message.raw_message)
        return unless message.has_attachment?

        file = bot.provider.file_builder(message.attachment)
        execution_context.add_file(file)
      end

      def save_token!(message)
        if message.command?
          execution_context.command = @channel_factory.command_or_default(message.command)
        else
          save_param!(message)
        end
      end

      def run_command_or_prepare!
        if execution_context.ready?
          run_command!
        else
          ask_param(execution_context.next_missing_param)
        end
      end

      def fallback(error)
        catch = @channel_factory.command(error.class)
        execution_context.command = catch if catch
      end

      # Method for triggering command
      def run_command!
        execution_context.call!(@dsl)
      rescue StandardError => e
        raise unless fallback(e)

        retry
      end

      # Sends a message to get the next parameter from the user
      def ask_param(param)
        provider = bot.provider
        msg = "I need you to tell me #{param}"
        log_debug(msg)
        provider.send_message(provider.last_message.channel_id, msg)
        execution_context.next_param = param
      end
    end
  end
end
