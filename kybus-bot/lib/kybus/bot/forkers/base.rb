# frozen_string_literal: true

module Kybus
  module Bot
    module Forkers
      class JobNotFound < ::Kybus::Bot::Base::BotError; end
      class JobNotReady < ::Kybus::Bot::Base::BotError; end

      extend Kybus::DRY::ResourceInjector
      register(:forkers, {})

      def self.register_forker(name, provider)
        forkers = resource(:forkers)
        forkers[name] = provider
      end

      def self.forker(name)
        forkers = resource(:forkers)
        forkers[name]
      end

      def self.from_config(bot, configs)
        provider_name = configs&.dig('provider') || 'thread'
        provider = forker(provider_name)
        provider.new(bot, configs)
      end

      class Base
        include Kybus::Logger

        def initialize(bot, configs)
          @configs = configs
          @bot = bot
          @command_definition = CommandDefinition.new
        end

        def register_command(command, arguments, &)
          @command_definition.register_command(command, arguments, &)
        end

        def fork(command, arguments, dsl, delay: 0)
          job_definition = @command_definition[command]
          raise JobNotFound if job_definition.nil?

          raise JobNotReady unless job_definition.ready?(arguments)

          invoke(command, arguments, job_definition, dsl, delay:)
        end

        def handle_job(command, args)
          job_definition = @command_definition[command]
          @bot.dsl.instance_eval do
            @args = args
            instance_eval(&job_definition.block)
          end
        end
      end
    end
  end
end
