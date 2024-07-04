# frozen_string_literal: true

module Kybus
  module Bot
    class CommandHandler
      def initialize(executor)
        @executor = executor
      end

      def run_command_or_prepare!
        if @executor.execution_context.ready?
          run_ready_command
        else
          ask_for_next_param
        end
      end

      private

      def run_ready_command
        @executor.dsl.state = @executor.execution_context.state
        @executor.dsl.instance_eval(&@executor.precommand_hook)
        msg = @executor.run_command!
        @executor.execution_context.clear_command
        msg
      end

      def ask_for_next_param
        param = @executor.execution_context.next_missing_param
        @executor.ask_param(param, @executor.execution_context.state.command.params_ask_label(param))
      end
    end
  end
end
