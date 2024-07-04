# frozen_string_literal: true

module Kybus
  module Bot
    class ExecutionContest
      include Kybus::Logger
      extend Forwardable

      attr_reader :state

      def_delegator :state, :requested_param=, :next_param=
      def_delegators :state, :clear_command, :save!, :ready?, :next_missing_param, :last_message=

      def block
        state.command.block
      end

      def call!(context)
        context.state = state
        statement = context.instance_eval(&block)
        clear_command
        statement
      end

      def initialize(channel_id, channel_factory)
        @channel_factory = channel_factory
        load_state!(channel_id)
      end

      # Stores a parameter into the status
      def add_param(value)
        param = state.requested_param
        return unless param

        log_debug('Received new param', param:, value:)
        state.store_param(param.to_sym, value)
      end

      def expecting_command?
        state.command.nil?
      end

      def add_file(file)
        param = state.requested_param
        return unless param

        log_debug('Received new file', param:, file: file.to_h)
        state.save_file(param.to_sym, file)
      end

      # Loads the state from storage
      def load_state!(channel)
        @state = @channel_factory.load_state(channel)
      end

      # stores the command into state
      def command=(cmd)
        log_debug('Message set as command', command: cmd.name)
        state.command = cmd
      end
    end
  end
end
