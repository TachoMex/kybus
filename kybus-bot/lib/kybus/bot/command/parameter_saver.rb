# frozen_string_literal: true

module Kybus
  module Bot
    class ParameterSaver
      def initialize(executor)
        @executor = executor
      end

      def save_token!(message)
        @executor.execution_context.last_message = message.serialize
        if @executor.execution_context.expecting_command?
          command = @executor.channel_factory.command(message.command)
          set_command(command, message)
        else
          save_param!(message)
        end
      end

      private

      def save_param!(message)
        @executor.execution_context.add_param(message.raw_message)
        save_attachment!(message) if message.has_attachment?
      end

      def save_attachment!(message)
        file = @executor.bot.provider.file_builder(message.attachment)
        @executor.execution_context.add_file(file)
      end

      def set_command(command, message)
        if @executor.inline_args && !command
          search_command_with_inline_arg(message)
        elsif !@executor.inline_args && !command
          set_default_command
        else
          @executor.execution_context.command = command
        end
      end

      def search_command_with_inline_arg(message)
        command, values = @executor.channel_factory.command_with_inline_arg(message.raw_message || '')
        if command
          set_command_with_values(command, values)
        else
          set_default_command
        end
      end

      def set_command_with_values(command, values)
        @executor.execution_context.command = command
        values.each do |value|
          @executor.execution_context.next_param = @executor.execution_context.next_missing_param
          @executor.execution_context.add_param(value)
        end
      end

      def set_default_command
        @executor.execution_context.command = @executor.channel_factory.default_command
      end
    end
  end
end
