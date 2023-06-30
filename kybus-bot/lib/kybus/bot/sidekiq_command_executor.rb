require 'sidekiq'

module Kybus
  module Bot
    class SidekiqWorker
      include Sidekiq::Worker
      extend Kybus::DRY::ResourceInjector
      include Kybus::Logger 

      def provider
        SidekiqWorker.resource(:provider)
      end

      def bot
        SidekiqWorker.resource(:bot)
      end

      def build_context(details_json)
        state = CommandState.from_json(details_json, bot.definitions)
        [DSLMethods.new(provider, state, bot), state]
      end

      def perform(details_json)
        dsl, state = build_context(details_json)
        dsl.instance_eval(&state.command.block)
      rescue StandardError => e
        log_error('Error in worker', error: e.class, msg: e.message, trace: e.backtrace)
      end
    end

    class SidekiqCommandExecutor < CommandExecutor
      def initialize(bot, channel_factory, configs)
        super(bot, channel_factory, configs['inline_args'])
        SidekiqWorker.register(:bot, bot)
        SidekiqWorker.register(:provider, bot.provider)
      end

      def run_command!
        log_info('Enqueued process to sidekiq', data: state)
        SidekiqWorker.perform_async(state.to_json)
        nil
      end
    end
  end
end
