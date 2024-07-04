# frozen_string_literal: true

require 'kybus/dry/daemon'
require 'kybus/bot/adapters/base'
require 'kybus/storage'
require_relative 'command/command_state'
require_relative 'dsl_methods'
require_relative 'command_executor'
require_relative 'command/command_definition'
require_relative 'command/execution_context'
require_relative 'command/command_state_factory'
require 'kybus/logger'
require 'forwardable'

module Kybus
  module Bot
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

      def initialize(configs)
        @pool_size = configs['pool_size']
        @provider = Kybus::Bot::Adapter.from_config(configs['provider'])
        @definitions = Kybus::Bot::CommandDefinition.new
        repository = create_repository(configs)
        command_factory = CommandStateFactory.new(repository, @definitions)
        @executor = create_executor(configs, command_factory)
        register_default_command
        register_abort_handler
        build_pool
      end

      def self.helpers(mod = nil, &)
        DSLMethods.include(mod) if mod
        DSLMethods.class_eval(&) if block_given?
      end

      def extend(*)
        DSLMethods.include(*)
      end

      def dsl
        @executor.dsl
      end

      def handle_message(msg)
        parsed = @provider.handle_message(msg)
        @executor.process_message(parsed)
      end

      def run
        pool.each(&:run)
        pool.each(&:await)
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

      def method_missing(method, ...) # rubocop: disable Style/MissingRespondToMissing
        return dsl.send(method, ...) if dsl.respond_to?(method)

        super
      end

      private

      def create_repository(configs)
        repository_config = configs['state_repository'].merge('primary_key' => 'channel_id', 'table' => 'bot_sessions')
        repository_config.merge!('fields' => DYNAMOID_FIELDS) if repository_config['name'] == 'dynamoid'
        Kybus::Storage::Repository.from_config(nil, repository_config, {})
      end

      def create_executor(configs, command_factory)
        if configs['sidekiq']
          require_relative 'sidekiq_command_executor'
          Kybus::Bot::SidekiqCommandExecutor.new(self, command_factory, configs)
        else
          Kybus::Bot::CommandExecutor.new(self, command_factory, configs['inline_args'])
        end
      end

      def register_default_command
        register_command('default') { nil }
      end

      def register_abort_handler
        rescue_from(Kybus::Bot::Base::AbortError) do
          msg = params[:_last_exception]&.message
          send_message(msg) if msg && msg != 'Kybus::Bot::Base::AbortError'
        end
      end

      def build_pool
        @pool = Array.new(pool_size) do
          Kybus::DRY::Daemon.new(pool_size, true) do
            message = provider.read_message
            executor.process_message(message)
          end
        end
      end
    end
  end
end
