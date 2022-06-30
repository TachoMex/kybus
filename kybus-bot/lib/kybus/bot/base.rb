# frozen_string_literal: true

require 'kybus/dry/daemon'
require 'kybus/bot/adapters/base'
require 'kybus/storage'
require_relative 'channel_state'
require_relative 'command_definition'
require_relative 'dsl_methods'
require_relative 'command_executor'

require 'kybus/logger'

module Kybus
  module Bot
    # Base class for bot implementation. It wraps the threads execution, the
    # provider and the state storage inside an object.
    class Base
      include Kybus::Storage::Datasource
      include Kybus::Logger
      include Kybus::Bot::DSLMethods
      include Kybus::Bot::CommandExecutor

      attr_reader :provider

      class BotError < StandardError; end

      class EmptyMessageError < BotError
        def initialize
          super('Message is empty')
        end
      end

      # Configurations needed:
      # - pool_size: number of threads created in execution
      # - provider: a configuration for a thread provider.
      #   See supported adapters
      # - name: The bot name
      # - repository: Configurations about the state storage
      def initialize(configs)
        @pool_size = configs['pool_size']
        @provider = Kybus::Bot::Adapter.from_config(configs['provider'])
        @commands = Kybus::Bot::CommandDefinition.new
        register_command('default') { nil }

        # TODO: move this to config
        @repository = Kybus::Storage::Repository.from_config(
          nil,
          configs['state_repository']
            .merge('primary_key' => 'channel_id',
                   'table' => 'bot_sessions'),
          {}
        )
        factory = Kybus::Storage::Factory.new(EmptyModel)
        factory.register(:default, :json)
        factory.register(:json, @repository)
        ChannelState.register(:factory, factory)
      end

      # Starts the bot execution, this is a blocking call.
      def run
        @pool = Array.new(@pool_size) do
          # TODO: Create a subclass with the context execution
          Kybus::DRY::Daemon.new(@pool_size, true) do
            message = provider.read_message
            @last_message = message
            process_message(message)
          end
        end
        # TODO: Implement an interface for killing the process
        @pool.each(&:run)
        # :nocov: #
        @pool.each(&:await)
        # :nocov: #
      end

      def add_file(file)
        return unless @state[:requested_param]

        log_debug('Received new file',
                  param: @state.requested_param.to_sym,
                  file: file.to_h)

        files[@state.requested_param.to_sym] = provider.file_builder(file)
        @state.store_param("_#{@state[:requested_param]}_filename".to_sym, file.file_name)
      end

      def registered_commands
        @commands.registered_commands
      end

      # validates which is the following parameter required
      def next_missing_param
        current_command_object.next_missing_param(current_params)
      end

      # Sends a message to get the next parameter from the user
      def ask_param(param)
        log_debug('I\'m going to ask the next param', param:)
        provider.send_message(current_channel,
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
      end

      # Private implementation for load message
      def load_state(channel)
        ChannelState.load_state(channel)
      end

      # Saves the state into storage
      def save_state!
        @state.save!
      end

      def session
        @repository
      end
    end
  end
end
