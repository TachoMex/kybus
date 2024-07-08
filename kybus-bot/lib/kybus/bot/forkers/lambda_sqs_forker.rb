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
          @queue_url = @client.get_queue_url(queue_name: @queue)
        end

        def invoke(command, args, _job_definition, dsl)
          @client.send_message(queue_url: @queue_url, message_body: make_message(command, args, dsl).to_json)
        end

        def make_message(command, args, dsl)
          {
            job: command,
            args: args.to_h,
            state: dsl.state.to_h
          }
        end
      end

      register_forker('sqs', LambdaSQSForker)
    end
  end
end
