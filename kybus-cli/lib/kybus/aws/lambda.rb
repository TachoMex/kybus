# frozen_string_literal: true

require 'digest'
require_relative 'layer_manager'

module Kybus
  module AWS
    class Lambda < Resource
      attr_reader :url, :name

      def initialize(configs, name)
        super(configs)
        @name = name
        @layer_manager = LayerManager.new(lambda_client, function_name)
      end

      def lambda_client
        @lambda_client ||= Aws::Lambda::Client.new(region: @region)
      end

      def function_name
        @name
      end

      def deploy_lambda!
        layer_arn_deps = @layer_manager.create_or_update_layer('.deps.zip', "#{function_name}-deps")

        if lambda_function_exists?
          update_lambda!(layer_arn_deps)
        else
          create_lambda!(layer_arn_deps)
        end
      end

      def lambda_function_exists?
        lambda_client.get_function(function_name:)
        true
      rescue Aws::Lambda::Errors::ResourceNotFoundException
        false
      end

      def update_lambda!(layer_arn_deps)
        update_function_configuration(layer_arn_deps)
        update_function_code
        puts "Lambda function '#{function_name}' updated."
      end

      def update_function_configuration(layer_arn_deps)
        with_retries(Aws::Lambda::Errors::ResourceConflictException) do
          lambda_client.update_function_configuration(
            function_name:,
            layers: [layer_arn_deps],
            timeout: @config['timeout'] || 3,
            environment: { variables: { 'SECRET_TOKEN' => @config['secret_token'] } }
          )
        end
      end

      def update_function_code
        with_retries(Aws::Lambda::Errors::ResourceConflictException) do
          lambda_client.update_function_code(
            function_name:,
            zip_file: File.read('.kybuscode.zip')
          )
        end
      end

      def codezip_setting
        { zip_file: File.read('.kybuscode.zip') }
      end

      def env_vars_settings
        { variables: { 'SECRET_TOKEN' => @config['secret_token'] } }
      end

      def create_lambda!(layer_arn_deps)
        with_retries(Aws::Lambda::Errors::ResourceConflictException) do
          lambda_client.create_function(
            function_name:, runtime: 'ruby3.3', role: "arn:aws:iam::#{account_id}:role/#{function_name}",
            handler: 'handler.lambda_handler', layers: [layer_arn_deps], code: codezip_setting,
            timeout: @config['timeout'] || 3, environment: env_vars_settings
          )
          puts "Lambda function '#{function_name}' created."
        end
      end

      def create_function_url
        @url = with_retries(Aws::Lambda::Errors::ResourceConflictException) do
          lambda_client.create_function_url_config(function_name:, auth_type: 'NONE')
        rescue Aws::Lambda::Errors::ResourceConflictException
          lambda_client.get_function_url_config(function_name:)
        end.url
        puts "Function URL created: #{@url}"
      end

      def add_public_permission
        with_retries(Aws::Lambda::Errors::ServiceError) do
          response = lambda_client.add_permission(
            function_name:,
            statement_id: 'AllowPublicInvoke',
            action: 'lambda:InvokeFunctionUrl',
            principal: '*',
            function_url_auth_type: 'NONE'
          )
          puts "Permission added successfully: #{response}"
        rescue Aws::Lambda::Errors::ServiceError => e
          puts "Error adding permission: #{e.message}"
        end
      end

      def create_or_update!
        deploy_lambda!
        create_function_url
        add_public_permission
      end

      def destroy!
        lambda_client.delete_function(function_name:)
        puts "Lambda function '#{function_name}' deleted."
      rescue Aws::Lambda::Errors::ResourceNotFoundException
        puts "Lambda function '#{function_name}' not found."
      end
    end
  end
end
