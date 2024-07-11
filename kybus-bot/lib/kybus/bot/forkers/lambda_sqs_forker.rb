# frozen_string_literal: true

module Kybus
  module Bot
    module Forkers
      class LambdaSQSForker < Base
        extend Kybus::DRY::ResourceInjector

        def self.register_queue_client(client)
          register(:sqs, client)
        end

        def initialize(bot, configs)
          super
          @client = LambdaSQSForker.resource(:sqs)
          @queue = configs['queue']
          @queue_url = @client.get_queue_url(queue_name: @queue).queue_url
        end

        def invoke(command, args, _job_definition, dsl, delay: 0)
          @client.send_message(queue_url: @queue_url,
                               message_body: make_message(command, args, dsl).to_json, delay_seconds: delay)
        end

        def make_message(command, args, dsl)
          {
            job: command,
            args: args.to_h,
            state: dsl.state.to_h
          }
        end

        def handle_job(command, args)
          log_info('Got job from SQS', command:)
          super
        end
      end

      register_forker('sqs', LambdaSQSForker)
    end
  end
end
