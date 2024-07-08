# frozen_string_literal: true

module Kybus
  module AWS
    class Queue < Resource
      attr_reader :queue_url, :name

      def initialize(configs, name)
        require 'aws-sdk-sqs'
        super(configs)
        @name = name
      end

      def sqs_client
        @sqs_client ||= Aws::SQS::Client.new(region: @region)
      end

      def create_or_update!
        create_queue!
        make_write_policy.create_or_update!
        make_processor_policy.create_or_update!
      end

      def create_queue!
        response = sqs_client.create_queue({
                                             queue_name: name,
                                             attributes: {
                                               'DelaySeconds' => '0',
                                               'MessageRetentionPeriod' => '86400'
                                             }
                                           })
        @queue_url = response.queue_url
        puts "Queue '#{name}' created with URL #{@queue_url}"
        @queue_url
      rescue Aws::SQS::Errors::QueueNameExists
        @queue_url = sqs_client.get_queue_url(name:).queue_url
        puts "Queue '#{name}' already exists with URL #{@queue_url}"
        @queue_url
      end

      def destroy!
        sqs_client.delete_queue(queue_url: @queue_url)
        puts "Queue '#{name}' deleted."
      rescue Aws::SQS::Errors::NonExistentQueue
        puts "Queue '#{name}' not found."
      end

      def arn
        "arn:aws:sqs:#{region}:#{account_id}:#{name}"
      end

      def queue_write_policy_document
        {
          Version: '2012-10-17',
          Statement: [
            {
              Effect: 'Allow',
              Action: [
                'sqs:Get*',
                'sqs:SendMessage'
              ],
              Resource: [
                arn
              ]
            }
          ]
        }
      end

      def queue_processor_policy_document
        {
          Version: '2012-10-17',
          Statement: [{
            Effect: 'Allow',
            Action: [
              'sqs:ReceiveMessage',
              'sqs:SendMessage',
              'sqs:Get*',
              'sqs:DeleteMEssage',
              'sqs:ChangeMessageVisibility'
            ],
            Resource: [arn]
          }]
        }
      end

      def make_write_policy
        policy_name = "#{name}_queue_publisher"
        @make_write_policy ||= Policy.new(@config, policy_name, queue_write_policy_document)
      end

      def make_processor_policy
        policy_name = "#{name}_queue_processor"
        @make_processor_policy ||= Policy.new(@config, policy_name, queue_processor_policy_document)
      end
    end
  end
end
