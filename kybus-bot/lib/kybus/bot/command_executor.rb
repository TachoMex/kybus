# frozen_string_literal: true

module Kybus
  module Bot
    module CommandExecutor
      # Process a single message, this method can be overwriten to enable
      # more complex implementations of commands. It receives a message object.
      def process_message(message)
        run_simple_command!(message)
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

      def run_simple_command!(message)
        load_state!(message.channel_id)
        log_debug('loaded state', message: message.to_h, state: @state.to_h)
        save_token!(message)
        try_command!
        save_state!
      rescue StandardError => e
        catch = @commands[e.class]
        raise if catch.nil?

        instance_eval(&catch.block)
        clear_command
      end

      # Method for triggering command
      def run_command!
        instance_eval(&current_command_object.block)
        clear_command
      end

      def clear_command
        @state.clear_command
      end

      # Checks if the command is ready to be executed
      def command_ready?
        cmd = current_command_object
        cmd.ready?(current_params)
      end

      # Loads command from state
      def current_command_object
        command = @state.command
        @commands[command] || @commands['default']
      end

      # stores the command into state
      def command=(cmd)
        log_debug('Message set as command', command: cmd)
        @state.command = cmd
      end
    end
  end
end
