# frozen_string_literal: true

module Kybus
  class CLI < Thor
    class AWSBotDeployer < BotDeployerBase # rubocop: disable Metrics/ClassLength
      def initialize(configs)
        configs['account_id'] = account_id
        super
        @region = @config['region'] || 'us-east-1'
        initialize_aws_resources(configs)
        assign_policies_to_role
      end

      def destroy!
        @lambda.destroy!
        @role.destroy!
        @dynamo_policy.destroy!
        @cloudwatch_policy.destroy!
        @log_group.destroy!
      end

      def url
        @lambda.url
      end

      def create_or_update!
        @log_group.create_or_update!
        @dynamo_policy.create_or_update!
        @cloudwatch_policy.create_or_update!
        @queue.create_or_update!
        @role.create_or_update!
        @lambda.create_or_update!
      end

      private

      def role_name
        function_name
      end

      def initialize_aws_resources(configs)
        @role = ::Kybus::AWS::Role.new(configs, role_name, :lambda)
        @dynamo_policy = ::Kybus::AWS::Policy.new(configs, "#{function_name}-dynamo", make_dynamo_policy_document)
        @cloudwatch_policy = ::Kybus::AWS::Policy.new(configs, "#{function_name}-cloudwatch",
                                                      make_log_group_policy_document)
        @log_group = ::Kybus::AWS::LogGroup.new(configs, function_name)
        @queue = Kybus::AWS::Queue.new(configs, function_name) if configs.dig('forker', 'queue')
        init_lambda(configs)
      end

      def lambda_config
        {
          'triggers' => [{ 'type' => 'url', 'public' => true }],
          'layers' => [
            {
              'type' => 'codezip', 'zipfile' => '.deps.zip',
              'checksumfile' => 'Gemfile.lock', 'name' => "#{function_name}-deps"
            }
          ]
        }
      end

      def init_lambda(configs)
        @lambda = ::Kybus::AWS::Lambda.new(configs.merge(lambda_config), function_name)
      end

      def assign_sqs_policy
        @role.add_policy(@queue.make_write_policy) if @queue
      end

      def assign_policies_to_role
        @role.add_policy(@dynamo_policy)
        @role.add_policy(@cloudwatch_policy)
        assign_sqs_policy
      end

      def make_dynamo_policy_document
        {
          Version: '2012-10-17',
          Statement: [
            dynamo_policy_allow_all,
            dynamo_policy_allow_describe
          ]
        }
      end

      def dynamo_policy_allow_all
        {
          Effect: 'Allow',
          Action: ['dynamodb:BatchGetItem', 'dynamodb:BatchWriteItem', 'dynamodb:Describe*', 'dynamodb:Get*',
                   'dynamodb:List*', 'dynamodb:PutItem', 'dynamodb:Query', 'dynamodb:Scan', 'dynamodb:UpdateItem',
                   'dynamodb:DeleteItem'],
          Resource: "arn:aws:dynamodb:#{@region}:#{account_id}:table/#{function_name}*"
        }
      end

      def dynamo_policy_allow_describe
        {
          Effect: 'Allow',
          Action: [
            'dynamodb:Describe*',
            'dynamodb:Get*',
            'dynamodb:List*'
          ],
          Resource: '*'
        }
      end

      def make_log_group_policy_document
        {
          Version: '2012-10-17',
          Statement: [
            log_group_policy_create_group,
            log_group_policy_create_stream_and_put_events
          ]
        }
      end

      def log_group_policy_create_group
        {
          Effect: 'Allow',
          Action: 'logs:CreateLogGroup',
          Resource: "arn:aws:logs:#{@region}:#{account_id}:*"
        }
      end

      def log_group_policy_create_stream_and_put_events
        {
          Effect: 'Allow',
          Action: [
            'logs:CreateLogStream',
            'logs:PutLogEvents'
          ],
          Resource: [
            "arn:aws:logs:#{@region}:#{account_id}:log-group:/aws/lambda/#{function_name}:*"
          ]
        }
      end
    end
  end
end
