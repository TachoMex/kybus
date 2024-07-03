# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'rake'
require 'securerandom'
require 'fileutils'
require 'yaml'
require 'aws-sdk-iam'
require 'aws-sdk-lambda'
require 'aws-sdk-cloudwatchlogs'
require 'zip'

require 'kybus/aws'
require_relative 'deployers/telegram_configurator'
require_relative 'deployers/aws_bot_deployer'

module Kybus
  class CLI < Thor
    class Deployer
      DEFAULT_CONFIGS = {
        'repo_path' => '.',
        'output_path' => './.kybusbotcode.zip'
      }.freeze

      def initialize(options)
        @params = options
        load_kybusdeploy_file!
        @telegram = ::Kybus::CLI::BotDeployerTelegramConfigurator.new(@url, config_with_options)
        @lambda = ::Kybus::CLI::AWSBotDeployer.new(config_with_options)
      end

      def run_migrations!
        Rake::Task.clear
        load 'Rakefile'
        Rake::Task['db:migrate'].invoke
      end

      def load_kybusdeploy_file!
        @config = YAML.load_file('./kybusbot.yaml')
      end

      def config_with_options
        @config_with_options ||= DEFAULT_CONFIGS.merge(@config.merge(@params))
      end

      def compress_repo!
        code = ::Kybus::AWS::CodePackager.new(config_with_options)
        code.create_or_update!
      end

      def deploy_lambda!
        @lambda.create_or_update!
        @telegram.url = @lambda.url
      end

      def run
        compress_repo!
        deploy_lambda!
        @telegram.create_or_update!
      end

      def destroy
        @lambda.destroy!
        @telegram.destroy!
      end
    end
  end
end
