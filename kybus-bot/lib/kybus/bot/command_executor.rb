# frozen_string_literal: true

require 'forwardable'

module Kybus
  module Bot
    class CommandExecutor
      extend Forwardable

      include Kybus::Logger
      attr_reader :state, :dsl

      def_delegator :@state, :clear_command
      def_delegators :@definitions, :registered_commands, :register_command
      def_delegator :@state, :channel_id, :current_channel
      def_delegator :@state, :params, :current_params
      def_delegator :@state, :save!, :save_state!

      def initialize(bot)
        @bot = bot
        @definitions = Kybus::Bot::CommandDefinition.new
        @dsl = DSLMethods.new(bot.provider, @state)
      end

      # Process a single message, this method can be overwriten to enable
      # more complex implementations of commands. It receives a message object.
      def process_message(message)
        load_state!(message.channel_id)
        @state.last_message = message
        log_debug('loaded state', message: message.to_h, state: @state.to_h)
        save_token!(message)
        try_command!
        save_state!
      rescue StandardError => e
        catch = @definitions[e.class]
        raise if catch.nil?

        @dsl.instance_eval(&catch.block)
        clear_command
      end

      def save_token!(message)
        if message.command?
          self.command = message.raw_message
        else
          add_param(message.raw_message)
          add_file(message.attachment) if message.has_attachment?
        end
      end

      def try_command!
        if command_ready?
          run_command!
        else
          ask_param(next_missing_param)
        end
      end

      def add_file(file)
        return unless @state.requested_param

        log_debug('Received new file',
                  param: @state.requested_param.to_sym,
                  file: file.to_h)

        @state.save_file(@state.requested_param.to_sym, @bot.provider.file_builder(file))
      end

      # Method for triggering command
      def run_command!
        @dsl.instance_eval(&current_command_object.block)
        clear_command
      end

      # Checks if the command is ready to be executed
      def command_ready?
        cmd = current_command_object
        cmd.ready?(current_params)
      end

      # Loads command from state
      def current_command_object
        command = @state.command
        @definitions[command] || @definitions['default']
      end

      # stores the command into state
      def command=(cmd)
        log_debug('Message set as command', command: cmd)
        @state.command = cmd
      end

      # validates which is the following parameter required
      def next_missing_param
        current_command_object.next_missing_param(current_params)
      end

      # Sends a message to get the next parameter from the user
      def ask_param(param)
        log_debug('I\'m going to ask the next param', param:)
        @bot.provider.send_message(current_channel,
                                   "I need you to tell me #{param}")
        @state.requested_param = param.to_s
      end

      # Stores a parameter into the status
      def add_param(value)
        return if @state.requested_param.nil?

        log_debug('Received new param',
                  param: @state.requested_param.to_sym,
                  value:)

        @state.store_param(@state.requested_param.to_sym, value)
      end

      # Loads the state from storage
      def load_state!(channel)
        @state = load_state(channel)
        @dsl.state = @state
      end

      # Private implementation for load message
      def load_state(channel)
        ChannelState.load_state(channel)
      end
    end
  end
end
