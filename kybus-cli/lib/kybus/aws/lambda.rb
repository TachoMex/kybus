# frozen_string_literal: true

require 'digest'

def calculate_md5(file_path)
  md5 = Digest::MD5.new
  File.open(file_path, 'rb') do |file|
    buffer = String.new
    md5.update(buffer) while file.read(4096, buffer)
  end
  md5.hexdigest
end

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
        layer_arn_deps = create_or_update_layer('.deps.zip', "#{function_name}-deps")

        function_exists = begin
          lambda_client.get_function(function_name:)
        rescue StandardError
          false
        end

        if function_exists
          update_lambda!(layer_arn_deps)
        else
          create_lambda!(layer_arn_deps)
        end
      end

      def create_layer(zip_file, layer_name, zipfile_hash)
        response = lambda_client.publish_layer_version({
                                                         layer_name:,
                                                         content: {
                                                           zip_file: File.read(zip_file)
                                                         },
                                                         description: zipfile_hash,
                                                         compatible_runtimes: ['ruby3.3']
                                                       })
        puts "Layer '#{layer_name}' created: #{response.layer_version_arn}"
        response.layer_version_arn
      end

      def create_or_update_layer(zip_file, layer_name)
        layer_exists = begin
          response = lambda_client.list_layer_versions({
                                                         layer_name:,
                                                         max_items: 1
                                                       })

          response.layer_versions.first
        end

        zipfile_hash = calculate_md5('Gemfile.lock')

        if !layer_exists || layer_exists.description != zipfile_hash
          create_layer(zip_file, layer_name, zipfile_hash)
        else
          puts "Layer unmodified: #{layer_name}"
          layer_exists.layer_version_arn
        end
      end

      def update_lambda!(layer_arn_deps)
        with_retries(Aws::Lambda::Errors::ResourceConflictException) do
          lambda_client.update_function_configuration({
                                                        function_name:,
                                                        layers: [layer_arn_deps],
                                                        timeout: @config['timeout'] || 3,
                                                        environment: {
                                                          variables: {
                                                            'SECRET_TOKEN' => @config['secret_token']
                                                          }
                                                        }
                                                      })
        end

        with_retries(Aws::Lambda::Errors::ResourceConflictException) do
          lambda_client.update_function_code(function_name:, zip_file: File.read('.kybuscode.zip'))
        end
        puts "Lambda function '#{function_name}' updated."
      end

      def create_lambda!(layer_arn_deps)
        with_retries(Aws::Lambda::Errors::ResourceConflictException) do
          lambda_client.create_function({
                                          function_name:,
                                          runtime: 'ruby3.3',
                                          role: "arn:aws:iam::#{account_id}:role/#{function_name}",
                                          handler: 'handler.lambda_handler',
                                          layers: [layer_arn_deps],
                                          code: {
                                            zip_file: File.read('.kybuscode.zip')
                                          },
                                          timeout: @config['timeout'] || 3,
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
