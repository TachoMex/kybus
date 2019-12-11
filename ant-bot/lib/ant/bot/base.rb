# frozen_string_literal: true

require 'ant/dry/daemon'
require 'ant/bot/adapters/base'
require 'ant/storage'
require_relative 'command_definition'

require 'ant/logger'

module Ant
  module Bot
    # Base class for bot implementation. It wraps the threads execution, the
    # provider and the state storage inside an object.
    class Base
      include Ant::Storage::Datasource
      include Ant::Logger
      # Configurations needed:
      # - pool_size: number of threads created in execution
      # - provider: a configuration for a thread provider.
      #   See supported adapters
      # - name: The bot name
      # - repository: Configurations about the state storage
      def initialize(configs)
        @pool_size = configs['pool_size']
        @provider = Ant::Bot::Adapter.from_config(configs['provider'])
        @commands = Ant::Bot::CommandDefinition.new

        # TODO: move this to config
        @repository = Ant::Storage::Repository.from_config(
          nil,
          configs['state_repository']
            .merge('primary_key' => 'channel_id',
                   'table' => 'bot_sessions'),
          {}
        )
        @factory = Ant::Storage::Factory.new(EmptyModel)
        @factory.register(:default, :json)
        @factory.register(:json, @repository)
      end

      def session
        @repository.connection
      end

      # Starts the bot execution, this is a blocking call.
      def run
        @pool = Array.new(@pool_size) do
          # TODO: Create a subclass with the context execution
          Ant::DRY::Daemon.new(@pool_size, true) do
            message = @provider.read_message
            process_message(message)
          end
        end
        # TODO: Implement an interface for killing the process
        @pool.each(&:run)
        # :nocov: #
        @pool.each(&:await)
        # :nocov: #
      end

      # Process a single message, this method can be overwriten to enable
      # more complex implementations of commands. It receives a message object.
      def process_message(message)
        run_simple_command!(message)
      end

      # Executes a command with the easiest definition. It runs a state machine:
      # - If the message is a command, set the status to asking params
      # - If the message is a param, stores it
      # - If the command is ready to be executed, trigger it.
      def run_simple_command!(message)
        load_state!(message.channel_id)
        log_debug('loaded state', message: message.to_h, state: @state.to_h)
        if message.command?
          self.command = message
        else
          add_param(message)
        end
        if command_ready?
          run_command!
        else
          ask_param(next_missing_param)
        end
        save_state!
      end

      # DSL method for adding simple commands
      def register_command(name, params, &block)
        @commands.register_command(name, params, block)
      end

      # Method for triggering command
      def run_command!
        current_command_object.execute(current_params)
      end

      # Checks if the command is ready to be executed
      def command_ready?
        cmd = current_command_object
        cmd.ready?(current_params)
      end

      # loads parameters from state
      def current_params
        @state[:params] || {}
      end

      # Loads command from state
      def current_command_object
        command = @state[:cmd]
        @commands[command]
      end

      # returns the current_channel from where the message was sent
      def current_channel
        @state[:channel_id]
      end

      # stores the command into state
      def command=(cmd)
        log_debug('Message set as command', command: cmd)

        @state[:cmd] = cmd.raw_message
        @state[:params] = {}
      end

      # validates which is the following parameter required
      def next_missing_param
        current_command_object.next_missing_param(current_params)
      end

      # Sends a message to get the next parameter from the user
      def ask_param(param)
        log_debug('I\'m going to ask the next param', param: param)
        @provider.send_message(current_channel,
                               "I need you to tell me #{param}")
        @state[:requested_param] = param.to_s
      end

      # Stores a parameter into the status
      def add_param(value)
        log_debug('Received new param',
                  param: @state[:requested_param].to_sym,
                  value: value)

        @state[:params][@state[:requested_param].to_sym] = value.raw_message
      end

      # Loads the state from storage
      def load_state!(channel)
        @state = load_state(channel)
      end

      # Private implementation for load message
      def load_state(channel)
        data = @factory.get(channel)
        data[:params] = JSON.parse(data[:params], symbolize_names: true)
        data
      rescue Ant::Storage::Exceptions::ObjectNotFound
        @factory.create(channel_id: channel, params: {}.to_json)
      end

      # Saves the state into storage
      def save_state!
        json = @state[:params]
        @state[:params] = json.to_json
        @state.store
        @state[:params] = json
      end
    end
  end
end
