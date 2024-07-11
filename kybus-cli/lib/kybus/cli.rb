# frozen_string_literal: true

require 'thor'
require_relative 'cli/bot'
require_relative 'cli/version'

module Kybus
  class CLI < Thor
    VERSION = KybusCLIVersion
    map %w[--version -v] => :__print_version

    desc '--version, -v', 'print the version'
    def __print_version
      puts Kybus::CLI::VERSION
    end

    desc 'bot SUBCOMMAND ...ARGS', 'Commands for managing bots'
    subcommand 'bot', Kybus::CLI::Bot

    def self.exit_on_failure?
      true
    end
  end
end
