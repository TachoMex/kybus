# frozen_string_literal: true

module Kybus
  module AWS
    class Lambda < Resource
      attr_reader :url, :name

      def initialize(configs, name)
        super(configs)
        @name = name
      end

      def lambda_client
        @lambda_client ||= Aws::Lambda::Client.new(region: @region)
      end

      def function_name
        @name
      end

      def deploy_lambda!
        function_exists = begin
          lambda_client.get_function(function_name:)
        rescue StandardError
          false
        end
        if function_exists
          update_lambda!
        else
          create_lambda!
        end
      end

      def update_lambda!
        with_retries(Aws::Lambda::Errors::ResourceConflictException) do
          lambda_client.update_function_code(function_name:, zip_file: File.read(@config['output_path']))
        end

        with_retries(Aws::Lambda::Errors::ResourceConflictException) do
          lambda_client.update_function_configuration({
                                                        function_name:,
                                                        environment: {
                                                          variables: {
                                                            'SECRET_TOKEN' => @config['secret_token']
                                                          }
                                                        }
                                                      })
        end
        puts "Lambda function '#{function_name}' updated."
      end

      def create_lambda!
        with_retries(Aws::Lambda::Errors::ResourceConflictException) do
          lambda_client.create_function({
                                          function_name:,
                                          runtime: 'ruby3.3',
                                          role: "arn:aws:iam::#{account_id}:role/#{function_name}-execution_role",
                                          handler: 'handler.lambda_handler',
                                          code: {
                                            zip_file: File.read(@config['output_path'])
                                          },
                                          environment: {
                                            variables: {
                                              'SECRET_TOKEN' => @config['secret_token']
                                            }
                                          }
                                        })
          puts "Lambda function '#{function_name}' created."
        end
      end

      def make_public!
        with_retries(Aws::Lambda::Errors::ResourceConflictException) do
          response = lambda_client.create_function_url_config({
                                                                function_name:,
                                                                auth_type: 'NONE'
                                                              })
          puts "Function URL created: #{response.function_url}"
          @url = response.function_url
        rescue Aws::Lambda::Errors::ResourceConflictException
          response = lambda_client.get_function_url_config({
                                                             function_name:
                                                           })
          puts "Function URL exists: #{response.function_url}"
          @url = response.function_url
        end
        begin
          response = lambda_client.add_permission({
                                                    function_name:,
                                                    statement_id: 'AllowPublicInvoke',
                                                    action: 'lambda:InvokeFunctionUrl',
                                                    principal: '*',
                                                    function_url_auth_type: 'NONE'
                                                  })
          puts "Permission added successfully: #{response}"
        rescue Aws::Lambda::Errors::ServiceError => e
          puts "Error adding permission: #{e.message}"
        end
      end

      def create_or_update!
        deploy_lambda!
        make_public!
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
