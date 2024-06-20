require 'thor'
require_relative 'bot/project_generator'
require_relative 'bot/controller_generator'

module Kybus
  class CLI < Thor
    class Bot < Thor
      desc "init NAME", "Initialize a new bot project"
      method_option :db_adapter, aliases: "-d", desc: "Database adapter (sequel, activerecord, dynamoid)", required: true
      method_option :with_simplecov, type: :boolean, default: false, desc: "Include SimpleCov for test coverage"
      method_option :with_docker_compose, type: :boolean, default: false, desc: 'Include docker compose template file'
      method_option :with_dockerfile, type: :boolean, default: false, desc: 'Include dockerfile template file'
      method_option :bot_provider, type: :string, default: 'REPLACE_ME', desc: 'Defines bot platform'
      method_option :bot_token, type: :string, default: 'REPLACE_ME', desc: 'Defines bot token for authentication under API'

      def init(name)
        Kybus::CLI::Bot::ProjectGenerator.new(name, options).generate
      end

      desc "add_controller NAME", "Add a new controller to the bot project"
      def add_controller(name)
        Kybus::CLI::Bot::ControllerGenerator.new(name).generate
      end
    end
  end
end

