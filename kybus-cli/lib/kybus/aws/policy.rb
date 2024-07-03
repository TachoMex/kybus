# frozen_string_literal: true

module Kybus
  module AWS
    class Policy < Resource
      attr_reader :name

      def initialize(config, name, body)
        super(config)
        @name = name
        @body = body
        @iam_client = Aws::IAM::Client.new
      end

      def arn
        "arn:aws:iam::#{account_id}:policy/#{name}"
      end

      def create_or_update!
        @iam_client.create_policy(policy_name: @name, policy_document: @body.to_json)
        puts "Policy '#{@name}' created."
      rescue Aws::IAM::Errors::EntityAlreadyExists
        puts "Policy '#{@name}' already exists."
      end

      def destroy!
        @iam_client.delete_policy(policy_arn: arn)
        puts "Policy '#{@name}' deleted."
      rescue Aws::IAM::Errors::NoSuchEntity
        puts "Policy '#{@name}' not found."
      end
    end
  end
end
