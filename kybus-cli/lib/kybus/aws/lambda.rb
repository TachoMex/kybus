# frozen_string_literal: true

require 'digest'
require_relative 'layer_manager'
require_relative 'lambda_trigger'

module Kybus
  module AWS
    class Lambda < Resource
      attr_reader :name

      def initialize(configs, name)
        super(configs)
        @name = name
        @layers = configs['layers']
        @triggers = configs['triggers']
        @layer_manager = LayerManager.new(lambda_client, function_name)
        @trigger_manager = LambdaTrigger.new(lambda_client, function_name, @triggers)
      end

      def lambda_client
        @lambda_client ||= Aws::Lambda::Client.new(region: @region)
      end

      def url
        @trigger_manager.url
      end

      def function_name
        @name
      end

      def deploy_lambda!
        layer_arns = @layers.map { |layer| handle_layer(layer) }

        if lambda_function_exists?
          update_lambda!(layer_arns)
        else
          create_lambda!(layer_arns)
        end
      end

      def handle_layer(layer)
        puts "Processing layer:\n#{layer.to_yaml}"
        case layer['type']
        when 'codezip'
          raise 'Checksum file required for codezip layer' unless layer['checksumfile']

          @layer_manager.create_or_update_layer(layer['zipfile'], layer['name'], layer['checksumfile'])
        when 'existing'
          layer_arn = @layer_manager.get_layer_arn(layer['name'])
          raise "Layer #{layer['name']} not found" unless layer_arn

          layer_arn
        else
          raise "Unknown layer type: #{layer['type']}"
        end
      end

      def lambda_function_exists?
        lambda_client.get_function(function_name:)
        true
      rescue Aws::Lambda::Errors::ResourceNotFoundException
        false
      end

      def update_lambda!(layer_arns)
        update_function_configuration(layer_arns)
        update_function_code
        puts "Lambda function '#{function_name}' updated."
      end

      def update_function_configuration(layer_arns)
        with_retries(Aws::Lambda::Errors::ResourceConflictException) do
          lambda_client.update_function_configuration(
            function_name:,
            layers: layer_arns,
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

      def create_lambda!(layer_arns)
        with_retries(Aws::Lambda::Errors::ResourceConflictException) do
          puts "Creating function #{function_name} with role: #{"arn:aws:iam::#{account_id}:role/#{function_name}"}"
          lambda_client.create_function(
            function_name:,
            runtime: 'ruby3.3',
            role: "arn:aws:iam::#{account_id}:role/#{function_name}",
            handler: @config['handler'] || 'handler.lambda_handler',
            layers: layer_arns,
            code: { zip_file: File.read('.kybuscode.zip') },
            timeout: @config['timeout'] || 3,
            environment: { variables: { 'SECRET_TOKEN' => @config['secret_token'] } }
          )
          puts "Lambda function '#{function_name}' created."
        end
      end

      def create_or_update!
        deploy_lambda!
        @trigger_manager.add_triggers
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
