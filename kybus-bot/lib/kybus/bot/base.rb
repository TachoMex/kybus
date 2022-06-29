# frozen_string_literal: true

require 'kybus/dry/daemon'
require 'kybus/bot/adapters/base'
require 'kybus/storage'
require_relative 'command_definition'

require 'kybus/logger'

module Kybus
  module Bot
    # Base class for bot implementation. It wraps the threads execution, the
    # provider and the state storage inside an object.
    class Base
      include Kybus::Storage::Datasource
      include Kybus::Logger
      attr_reader :provider

      class BotError < StandardError; end

      class EmptyMessageError < BotError
        def initialize
          super('Message is empty')
        end
      end

      def send_message(content, channel = nil)
        raise(EmptyMessageError) unless content

        provider.send_message(channel || current_channel, content)
      end

      def rescue_from(klass, &block)
        @commands.register_command(klass, [], block)
      end

      def send_image(content, channel = nil)
        provider.send_image(channel || current_channel, content)
      end

      def send_audio(content, channel = nil)
        provider.send_audio(channel || current_channel, content)
      end

      def send_document(content, channel = nil)
        provider.send_document(channel || current_channel, content)
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
        register_command('default') { ; }

        # TODO: move this to config
        @repository = Kybus::Storage::Repository.from_config(
          nil,
          configs['state_repository']
            .merge('primary_key' => 'channel_id',
                   'table' => 'bot_sessions'),
          {}
        )
        @factory = Kybus::Storage::Factory.new(EmptyModel)
        @factory.register(:default, :json)
        @factory.register(:json, @repository)
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
          self.command = message.raw_message
        else
          add_param(message.raw_message)
          add_file(message.attachment) if message.has_attachment?
        end
        if command_ready?
          run_command!
        else
          ask_param(next_missing_param)
        end
        save_state!
      rescue StandardError => e
        catch = @commands[e.class]
        raise if catch.nil?

        instance_eval(&catch.block)
        clear_command
      end

      # DSL method for adding simple commands
      def register_command(name, params = [], &block)
        @commands.register_command(name, params, block)
      end

      # Method for triggering command
      def run_command!
        instance_eval(&current_command_object.block)
        clear_command
      end

      def clear_command
        @state[:cmd] = nil
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

      def params
        current_params
      end

      def add_file(file)
        return if @state[:requested_param].nil?

        log_debug('Received new file',
                  param: @state[:requested_param].to_sym,
                  file: file.to_h)

        files[@state[:requested_param].to_sym] = provider.file_builder(file)
        @state[:params]["_#{@state[:requested_param]}_filename".to_sym] = file.file_name
      end

      def files
        @state[:files] ||= {}
      end

      def file(name)
        (file = files[name]) && provider.file_builder(file)
      end

      def mention(name)
        provider.mention(name)
      end

      def registered_commands
        @commands.registered_commands
      end

      # Loads command from state
      def current_command_object
        command = @state[:cmd]
        @commands[command] || @commands['default']
      end

      # returns the current_channel from where the message was sent
      def current_channel
        @state[:channel_id]
      end

      def current_user
        @last_message.user
      end

      def is_private?
        @last_message.is_private?
      end

      # stores the command into state
      def command=(cmd)
        log_debug('Message set as command', command: cmd)

        @state[:cmd] = cmd.split(' ').first
        @state[:params] = {}
        @state[:files] = {}
      end

      # validates which is the following parameter required
      def next_missing_param
        current_command_object.next_missing_param(current_params)
      end

      # Sends a message to get the next parameter from the user
      def ask_param(param)
        log_debug('I\'m going to ask the next param', param: param)
        provider.send_message(current_channel,
                              "I need you to tell me #{param}")
        @state[:requested_param] = param.to_s
      end

      # Stores a parameter into the status
      def add_param(value)
        return if @state[:requested_param].nil?

        log_debug('Received new param',
                  param: @state[:requested_param].to_sym,
                  value: value)

        @state[:params][@state[:requested_param].to_sym] = value
      end

      # Loads the state from storage
      def load_state!(channel)
        @state = load_state(channel)
      end

      # Private implementation for load message
      def load_state(channel)
        data = @factory.get(channel)
        data[:params] = JSON.parse(data[:params] || '{}', symbolize_names: true)
        data[:files] = JSON.parse(data[:files] || '{}', symbolize_names: true)
        data
      rescue Kybus::Storage::Exceptions::ObjectNotFound
        @factory.create(channel_id: channel, params: {}.to_json)
      end

      def parse_state!; end

      # Saves the state into storage
      def save_state!
        backup = @state.clone
        %i[params files].each do |param|
          @state[param] = @state[param].to_json
        end

        @state.store
        %i[params files].each do |param|
          @state[param] = backup[param]
        end
      end

      def session
        @repository
      end
    end
  end
end
