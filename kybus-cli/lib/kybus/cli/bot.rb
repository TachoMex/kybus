# frozen_string_literal: true

require 'thor'
require_relative 'bot/project_generator'
require_relative 'bot/controller_generator'
require_relative 'bot/deployer'

module Kybus
  class CLI < Thor
    class Bot < Thor
      desc 'init NAME', 'Initialize a new bot project'
      method_option :db_adapter, aliases: '-d', desc: 'Database adapter (sequel, activerecord, dynamoid)',
                                 required: true
      method_option :with_simplecov, type: :boolean, default: false, desc: 'Include SimpleCov for test coverage'
      method_option :with_docker_compose, type: :boolean, default: false, desc: 'Include docker compose template file'
      method_option :with_dockerfile, type: :boolean, default: false, desc: 'Include dockerfile template file'
      method_option :bot_provider, type: :string, default: 'REPLACE_ME', desc: 'Defines bot platform'
      method_option :bot_token, type: :string, default: 'REPLACE_ME',
                                desc: 'Defines bot token for authentication under API'
      method_option :with_deployment_file, type: :boolean, default: false, desc: 'Include deployment configuration file'
      method_option :cloud_provider, aliases: '-c', desc: 'Cloud provider (default: aws)', default: 'aws'
      method_option :vpc, aliases: '-v', desc: 'VPC ID', default: 'REPLACE_ME'
      method_option :subnets, aliases: '-s', desc: 'Subnets', default: 'REPLACE_ME'
      method_option :dynamo_capacity, aliases: '-d', desc: 'DynamoDB capacity (on_demand or provisioned)',
                                      default: 'REPLACE_ME'
      method_option :dynamo_table, aliases: '-t', desc: 'DynamoDB table name', default: 'REPLACE_ME'

      def init(name)
        Kybus::CLI::Bot::ProjectGenerator.new(name, options).generate
      end

      desc 'add_controller NAME', 'Add a new controller to the bot project'
      def add_controller(name)
        Kybus::CLI::Bot::ControllerGenerator.new(name).generate
      end

      desc 'deploy-init', 'Initialize deployment configurations'
      method_option :cloud_provider, aliases: '-c', desc: 'Cloud provider (default: aws)', default: 'aws'
      method_option :vpc, aliases: '-v', desc: 'VPC ID'
      method_option :subnets, aliases: '-s', desc: 'Subnets'
      method_option :dynamo_capacity, aliases: '-d', desc: 'DynamoDB capacity (on_demand or provisioned)'
      method_option :dynamo_table, aliases: '-t', desc: 'DynamoDB table name'
      method_option :chat_provider, aliases: '-p', desc: 'Chat provider (default: telegram)'

      def deploy_init(name)
        DeployInitGenerator.new(name, options).generate
      end

      desc 'deploy', 'Deploy the bot to AWS'
      def deploy
        ::Kybus::CLI::Deployer.new(options).run
      end

      desc 'destroy', 'Destroys the provisiones infrastructure in AWS'
      def destroy
        ::Kybus::CLI::Deployer.new(options).destroy
      end
    end
  end
end
