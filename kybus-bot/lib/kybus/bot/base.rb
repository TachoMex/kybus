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
require_relative 'exceptions'
require_relative 'forkers/base'
require_relative 'forkers/thread_forker'
require_relative 'forkers/lambda_sqs_forker'
require 'kybus/logger'
require 'forwardable'

module Kybus
  module Bot
    # Main bot runtime: command registry, provider IO, and state management.
    class Base # rubocop: disable Metrics/ClassLength
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
        create_executor(configs, command_factory)
        register_default_command
        register_abort_handler
        build_forker(configs)
        build_pool
      end

      # Extend DSL methods available inside command blocks.
      def self.helpers(mod = nil, &)
        DSLMethods.include(mod) if mod
        DSLMethods.class_eval(&) if block_given?
      end

      # Enable automatic help and hints injection for commands.
      def self.enable_command_help!
        Kybus::Bot::CommandHelp.apply!(self)
      end

      def extend(*)
        DSLMethods.include(*)
      end

      # Returns the DSL context used to execute commands.
      def dsl
        @executor.dsl
      end

      # Process an incoming provider message (webhook mode).
      def handle_message(msg)
        parsed = @provider.handle_message(msg)
        @executor.process_message(parsed)
      end

      # Execute a background job (used by async forkers).
      def handle_job(job, args, channel_id)
        @executor.load_state!(channel_id)
        @forker.handle_job(job, args)
        @executor.save_state!
      end

      def run
        pool.each(&:run)
        pool.each(&:await)
      end

      # Redirect execution to another command with params.
      def redirect(command, *params)
        @executor.redirect(command, params)
      end

      # Send a message through the provider.
      def send_message(contents, channel)
        log_debug('Sending message', contents:, channel:)
        provider.message_builder(@provider.send_message(contents, channel))
      end

      # Register a paginated query command with enhanced UX rendering.
      def define_paginated_query(command, params: [], hint: nil, per_page: 10, &block)
        register_command(command, params, hint: hint) do
          @bot.run_paginated_query(self, command, params, per_page, &block)
        end
      end

      # Render a paginated response using the active UX renderer.
      def run_paginated_query(dsl, command, params, per_page, &block)
        args = Array(params).map { |param| dsl.params[param] }
        last_arg = args.last
        value, page = split_value_page(last_arg || dsl.last_message.raw_message)
        args[-1] = value if args.any?

        result = block.call(dsl, *args, page, per_page)
        total_pages = result[:total_pages] || 1
        text = result[:text] || [result[:header], result[:body], result[:nav]].compact.join("\n")
        key = result[:key] || "#{command}:#{args.compact.join(':')}"
        prev_cmd = result[:prev_cmd] || (page > 1 ? build_paginated_command(command, args, page - 1) : nil)
        next_cmd = result[:next_cmd] || (page < total_pages ? build_paginated_command(command, args, page + 1) : nil)

        ux.render_paginated(dsl, key:, text:, prev_cmd:, next_cmd:)
      end

      # Returns the UX renderer for the current provider.
      def ux
        @ux ||= Kybus::Bot::UX.for(provider)
      end

      # Register a command and its params.
      def register_command(klass, params = [], &)
        definitions.register_command(klass, params, &)
      end

      # Register a background job handler.
      def register_job(name, args = {}, &)
        @forker.register_command(name, args, &)
      end

      # Enqueue a background job.
      def invoke_job(name, args)
        @forker.fork(name, args, dsl)
      end

      # Enqueue a background job with delay.
      def invoke_job_with_delay(name, delay, args)
        @forker.fork(name, args, dsl, delay:)
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

      def split_value_page(raw)
        token = raw.to_s
        value, page_str = token.split(/__|\s+/, 2)
        page = page_str.to_i
        page = 1 if page <= 0
        [value, page]
      end

      def build_paginated_command(command, args, page)
        base = command.to_s
        base += args.first.to_s if args.any? && !args.first.to_s.empty?
        "#{base}__#{page}"
      end

      def create_executor(configs, command_factory)
        @executor = if configs['sidekiq']
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

      def build_forker(configs)
        @forker = Forkers.from_config(self, configs['forker'])
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
