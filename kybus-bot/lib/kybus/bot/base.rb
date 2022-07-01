# frozen_string_literal: true

require 'kybus/dry/daemon'
require 'kybus/bot/adapters/base'
require 'kybus/storage'
require_relative 'channel_state'
require_relative 'command_definition'
require_relative 'dsl_methods'
require_relative 'command_executor'

require 'kybus/logger'
require 'forwardable'

module Kybus
  module Bot
    # Base class for bot implementation. It wraps the threads execution, the
    # provider and the state storage inside an object.
    class Base
      class BotError < StandardError; end

      class EmptyMessageError < BotError
        def initialize
          super('Message is empty')
        end
      end

      extend Forwardable
      include Kybus::Storage::Datasource
      include Kybus::Logger

      attr_reader :provider

      def_delegators :@commands, :registered_commands, :state

      # Configurations needed:
      # - pool_size: number of threads created in execution
      # - provider: a configuration for a thread provider.
      #   See supported adapters
      # - name: The bot name
      # - repository: Configurations about the state storage
      def initialize(configs)
        @pool_size = configs['pool_size']
        @provider = Kybus::Bot::Adapter.from_config(configs['provider'])
        @commands = Kybus::Bot::CommandExecutor.new(self)
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
            @commands.process_message(message)
          end
        end
        # TODO: Implement an interface for killing the process
        @pool.each(&:run)
        # :nocov: #
        @pool.each(&:await)
        # :nocov: #
      end

      def register_command(klass, params = [], &block)
        @commands.register_command(klass, params, &block)
      end

      def rescue_from(klass, &block)
        @commands.register_command(klass, [], &block)
      end

      def session
        @repository
      end
    end
  end
end
