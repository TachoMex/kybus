# frozen_string_literal: true

module Kybus
  module Bot
    # Command help and hints decorator for Base.
    module CommandHelp
      def self.apply!(klass)
        return if klass < InstanceMethods

        klass.prepend(InstanceMethods)
      end

      module InstanceMethods
        def register_command(command, params = nil, hint: nil, **param_labels, &block)
          return super(command, params || [], &block) if help_registering?

          init_command_help!
          params = param_labels if params.nil? && param_labels.any?
          track_command_help(command, params, hint)
          params = [] if params.nil?
          result = super(command, params, &block)
          register_help_command_for(command)
          register_help_overview_command
          result
        end

        def help_overview
          return '∅' if @command_help.empty?

          lines = @command_help.keys.sort.map do |command|
            info = @command_help[command]
            usage = format_usage(command, info[:args])
            hint = info[:hint]
            hint ? "#{usage} • #{hint}" : usage
          end
          ["🧭 #{@command_help.size}", lines.join("\n")].join("\n")
        end

        def help_for_command(command)
          info = @command_help[command]
          return '∅' if info.nil?

          usage = format_usage(command, info[:args])
          lines = ["⚙ #{command}", "▶ #{usage}"]
          lines << "💡 #{info[:hint]}" if info[:hint]
          lines << "❓ #{help_command_for(command)}"
          lines.join("\n")
        end

        private

        def init_command_help!
          @command_help ||= {}
        end

        def help_registering?
          @help_registering ||= false
        end

        def track_command_help(command, params, hint)
          return if command == 'default'

          args = params.is_a?(Hash) ? params.keys : Array(params)
          @command_help[command] = {
            hint: hint,
            args: args
          }
        end

        def format_usage(command, args)
          arg_list = Array(args).map { |arg| "<#{arg}>" }.join(' ')
          [command, arg_list].reject(&:empty?).join(' ')
        end

        def help_command_for(command)
          base = command.to_s.sub(%r{\A/}, '')
          "/help_#{base}"
        end

        def register_help_overview_command
          return if registered_commands.include?('/help')

          @help_registering = true
          register_command('/help') do
            overview = @bot.help_overview
            commands = @command_help.keys.sort
            @bot.ux.render_help_overview(self, text: overview, commands: commands)
          end
        ensure
          @help_registering = false
        end

        def register_help_command_for(command)
          return if command == 'default'
          return if command == '/help'
          return if command.to_s.start_with?('/help_')

          help_command = help_command_for(command)
          @help_registering = true
          register_command(help_command) do
            detail = @bot.help_for_command(command)
            @bot.ux.render_help_command(self, text: detail)
          end
        ensure
          @help_registering = false
        end
      end
    end
  end
end
