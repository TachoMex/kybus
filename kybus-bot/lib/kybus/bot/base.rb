# frozen_string_literal: true

require 'kybus/dry/daemon'
require 'kybus/bot/adapters/base'
require 'kybus/storage'
require_relative 'command/command_state'
require_relative 'dsl_methods'
require_relative 'command_executor'
require_relative 'command/command_state_factory'

require 'kybus/logger'
require 'forwardable'

module Kybus
  module Bot
    # Base class for bot implementation. It wraps the threads execution, the
    # provider and the state storage inside an object.
    class Base
      class BotError < StandardError; end
      class AbortError < BotError; end

      class EmptyMessageError < BotError
        def initialize
          super('Message is empty')
        end
      end

      extend Forwardable
      include Kybus::Logger

      attr_reader :provider, :executor, :pool_size, :pool, :definitions

      DYNAMOID_FIELDS = {
        'channel_id' => :string,
        'user' => :string,
        'params' => :string,
        'metadata' => :string,
        'files' => :string,
        'cmd' => :string,
        'requested_param' => :string,
        'last_message' => :string
      }.freeze

      def_delegators :executor, :state, :precommand_hook
      def_delegators :definitions, :registered_commands

      # Configurations needed:
      # - pool_size: number of threads created in execution
      # - provider: a configuration for a thread provider.
      #   See supported adapters
      # - name: The bot name
      # - repository: Configurations about the state storage

      def initialize(configs)
        build_pool(configs['pool_size'])
        @provider = Kybus::Bot::Adapter.from_config(configs['provider'])
        # TODO: move this to config
        repository = make_repository(configs)
        @definitions = Kybus::Bot::CommandDefinition.new
        command_factory = CommandStateFactory.new(repository, @definitions)
        @executor = if configs['sidekiq']
                      require_relative 'sidekiq_command_executor'
                      Kybus::Bot::SidekiqCommandExecutor.new(self, command_factory, configs)
                    else
                      Kybus::Bot::CommandExecutor.new(self, command_factory, configs['inline_args'])
                    end
        register_command('default') { nil }
        rescue_from(::Kybus::Bot::Base::AbortError) do
          msg = params[:_last_exception]&.message
          send_message(msg) if msg && msg != "Kybus::Bot::Base::AbortError"
        end
      end

      def make_repository(configs)
        repository_config = configs['state_repository'].merge('primary_key' => 'channel_id', 'table' => 'bot_sessions')
        repository_config.merge!('fields' => DYNAMOID_FIELDS) if repository_config['name'] == 'dynamoid'
        Kybus::Storage::Repository.from_config(nil, repository_config, {})
      end

      def extend(*args)
        DSLMethods.include(*args)
      end

      def self.helpers(mod = nil, &)
        DSLMethods.include(mod) if mod
        DSLMethods.class_eval(&) if block_given?
      end

      def build_pool(pool_size)
        @pool = Array.new(pool_size) do
          # TODO: Create a subclass with the context execution
          Kybus::DRY::Daemon.new(pool_size, true) do
            message = provider.read_message
            executor.process_message(message)
          end
        end
      end

      def dsl
        @executor.dsl
      end

      def handle_message(msg)
        parsed = @provider.handle_message(msg)
        @executor.process_message(parsed)
      end

      # Starts the bot execution, this is a blocking call.
      def run
        # TODO: Implement an interface for killing the process
        pool.each(&:run)
        # :nocov: #
        pool.each(&:await)
        # :nocov: #
      end

      def redirect(command, *params)
        @executor.redirect(command, params)
      end

      def send_message(contents, channel)
        log_debug('Sending message', contents:, channel:)
        provider.message_builder(@provider.send_message(contents, channel))
      end

      def register_command(klass, params = [], &)
        definitions.register_command(klass, params, &)
      end

      def rescue_from(klass, &)
        definitions.register_command(klass, [], &)
      end

      def method_missing(method, ...)
        raise unless dsl.respond_to?(method)

        dsl.send(method, ...)
      end
    end
  end
end
