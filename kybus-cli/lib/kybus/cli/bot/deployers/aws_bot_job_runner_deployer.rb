# frozen_string_literal: true

module Kybus
  class CLI < Thor
    class AWSBotJobRunnerDeployer < AWSBotDeployer
      def lambda_config
        {
          'triggers' => [{ 'type' => 'sqs', 'queue_arn' => @queue.arn }], 'layers' => [
            { 'type' => 'existing', 'name' => "#{function_name}-deps" }
          ]
        }
      end

      def role_name
        "#{function_name}_job_processor"
      end

      def init_lambda(configs)
        @lambda = ::Kybus::AWS::Lambda.new(configs.merge(lambda_config), role_name)
      end

      def assign_sqs_policy
        @role.add_policy(@queue.make_processor_policy) if @queue
      end
    end
  end
end
