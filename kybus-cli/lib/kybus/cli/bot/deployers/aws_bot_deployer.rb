# frozen_string_literal: true

module Kybus
  class CLI < Thor
    class AWSBotDeployer < BotDeployerBase
      def make_dynamo_policy_document
        {
          Version: '2012-10-17',
          Statement: [
            {
              Effect: 'Allow',
              Action: [
                'dynamodb:BatchGetItem',
                'dynamodb:BatchWriteItem',
                'dynamodb:Describe*',
                'dynamodb:Get*',
                'dynamodb:List*',
                'dynamodb:PutItem',
                'dynamodb:Query',
                'dynamodb:Scan',
                'dynamodb:UpdateItem',
                'dynamodb:DeleteItem'
              ],
              Resource: "arn:aws:dynamodb:#{@region}:#{account_id}:table/#{function_name}*"
            }, {
              Effect: :Allow,
              Action: [
                'dynamodb:Describe*',
                'dynamodb:Get*',
                'dynamodb:List*'
              ],
              Resource: '*'
            }
          ]
        }
      end

      def make_log_groupo_policy_document
        {
          Version: '2012-10-17',
          Statement: [
            {
              Effect: 'Allow',
              Action: 'logs:CreateLogGroup',
              Resource: "arn:aws:logs:#{@region}:#{account_id}:*"
            },
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
          ]
        }
      end

      def initialize(configs)
        configs['account_id'] = account_id
        super
        @region = @config['region'] || 'us-east-1'
        @role = ::Kybus::AWS::Role.new(configs, function_name, :lambda)
        @dynamo_policy = ::Kybus::AWS::Policy.new(configs, "#{function_name}-dynamo", make_dynamo_policy_document)
        @cloudwatch_policy = ::Kybus::AWS::Policy.new(configs, "#{function_name}-cloudwatch",
                                                      make_log_groupo_policy_document)
        @role.add_policy(@dynamo_policy)
        @role.add_policy(@cloudwatch_policy)
        @log_group = ::Kybus::AWS::LogGroup.new(configs, function_name)
        @lambda = ::Kybus::AWS::Lambda.new(configs, function_name)
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
        @role.create_or_update!
        @lambda.create_or_update!
      end
    end
  end
end
