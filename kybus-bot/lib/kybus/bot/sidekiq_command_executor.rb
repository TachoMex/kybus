# frozen_string_literal: true

require 'sidekiq'
require_relative 'sidekiq_dsl_methods'

module Kybus
  module Bot
    # Sidekiq worker for executing command blocks asynchronously.
    class SidekiqWorker
      include Sidekiq::Worker
      extend Kybus::DRY::ResourceInjector
      include Kybus::Logger

      def provider
        SidekiqWorker.resource(:provider)
      end

      def factory
        SidekiqWorker.resource(:factory)
      end

      def bot
        SidekiqWorker.resource(:bot)
      end

      # Build DSL context and state from serialized data.
      def build_context(details_json)
        state = CommandState.from_json(details_json, factory)
        log_debug('Loaded message into worker', state: state.to_h)
        [SidekiqDSLMethods.new(provider, state, bot, factory), state]
      end

      def perform(details_json)
        dsl, state = build_context(details_json)
        dsl.instance_eval(&state.command.block)
      rescue StandardError => e
        # :nocov:
        log_error('Error in worker', error: e.class, msg: e.message, trace: e.backtrace)
        # :nocov:
      end
    end

    # Command executor that enqueues work into Sidekiq.
    class SidekiqCommandExecutor < CommandExecutor
      def initialize(bot, channel_factory, configs)
        super(bot, channel_factory, configs['inline_args'])
        SidekiqWorker.register(:factory, @channel_factory)
        SidekiqWorker.register(:provider, bot.provider)
        SidekiqWorker.register(:bot, bot)
      end

      # Enqueue the command execution and return nil.
      def run_command!
        log_debug(msg: 'Enqueued process to sidekiq', state: state.to_h)
        SidekiqWorker.perform_async(state.to_json)
        nil
      end
    end
  end
end
