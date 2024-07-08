# frozen_string_literal: true

module Kybus
  module AWS
    class LambdaTrigger
      def initialize(lambda_client, function_name, triggers)
        @lambda_client = lambda_client
        @function_name = function_name
        @triggers = triggers
      end

      def add_triggers
        @triggers.each do |trigger|
          case trigger['type']
          when 'url'
            create_function_url(trigger['public'])
          when 'sqs'
            add_sqs_trigger(trigger['queue_arn'])
          else
            raise "Unknown trigger type: #{trigger['type']}"
          end
        end
      end

      private

      def create_function_url(is_public)
        @url = begin
          @lambda_client.create_function_url_config(function_name: @function_name, auth_type: 'NONE')
        rescue Aws::Lambda::Errors::ResourceConflictException
          @lambda_client.get_function_url_config(function_name: @function_name)
        end.function_url
        puts "Function URL created: #{@url}"

        return unless is_public

        add_public_permission
      end

      def add_public_permission
        response = @lambda_client.add_permission(
          function_name: @function_name,
          statement_id: 'AllowPublicInvoke',
          action: 'lambda:InvokeFunctionUrl',
          principal: '*',
          function_url_auth_type: 'NONE'
        )
        puts "Permission added successfully: #{response}"
      rescue Aws::Lambda::Errors::ServiceError => e
        puts "Error adding permission: #{e.message}"
      end

      def add_sqs_trigger(queue_arn)
        raise("Invalid ARN for queue: #{queue_arn}") if queue_arn.nil?

        puts "Adding trigger for lambda: #{@function_name} with sqs #{queue_arn}"
        @lambda_client.create_event_source_mapping({
                                                     event_source_arn: queue_arn,
                                                     function_name: @function_name,
                                                     enabled: true,
                                                     batch_size: 10
                                                   })
        puts "SQS trigger added to Lambda function '#{@function_name}' for queue '#{queue_arn}'."
      end
    end
  end
end
