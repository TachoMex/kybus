# frozen_string_literal: true

module Kybus
  module AWS
    class Role < Resource
      LAMBDA_ASSUME_ROLE_POLICY = {
        Version: '2012-10-17',
        Statement: [
          {
            Effect: 'Allow',
            Principal: {
              Service: 'lambda.amazonaws.com'
            },
            Action: 'sts:AssumeRole'
          }
        ]
      }.to_json.freeze

      def initialize(config, name, type)
        super(config)
        @type = type
        @name = name
        @iam_client = Aws::IAM::Client.new
        @policies = []
      end

      def add_policy(policy)
        @policies << policy
      end

      def assume_role_policy
        case @type
        when :lambda
          LAMBDA_ASSUME_ROLE_POLICY
        else
          raise 'Invalid Role Type'
        end
      end

      def create_or_update!
        begin
          @iam_client.create_role({
                                    role_name: @name,
                                    assume_role_policy_document: assume_role_policy
                                  })
          puts "Role '#{@name}' created."
        rescue Aws::IAM::Errors::EntityAlreadyExists
          puts "Role '#{@name}' already exists."
        end

        @policies.each do |policy|
          @iam_client.attach_role_policy(role_name: @name, policy_arn: policy.arn)
          puts "Policy '#{policy.name}' attached to role '#{@name}'."
        rescue Aws::IAM::Errors::EntityAlreadyExists
          puts "Policy '#{policy.name}' already attached to role '#{@name}'."
        end
      end

      def destroy!
        @policies.each do |policy|
          @iam_client.detach_role_policy({ role_name: @name, policy_arn: policy.arn })
          puts "Policy '#{policy.name}' deleted."
        rescue Aws::IAM::Errors::NoSuchEntity
          puts "Policy '#{policy.name}' not found."
        end

        begin
          @iam_client.delete_role(role_name: @name)
          puts "Role '#{@name}' deleted."
        rescue Aws::IAM::Errors::NoSuchEntity
          puts "Role '#{@name}' not found."
        end
      end
    end
  end
end
