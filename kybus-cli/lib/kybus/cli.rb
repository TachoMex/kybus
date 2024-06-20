require 'thor'
require_relative 'cli/bot'

module Kybus
  class CLI < Thor
    desc "bot SUBCOMMAND ...ARGS", "Commands for managing bots"
    subcommand "bot", Kybus::CLI::Bot

    def self.exit_on_failure?
      true
    end
  end
end
