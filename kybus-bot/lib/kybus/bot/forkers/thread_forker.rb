# frozen_string_literal: true

module Kybus
  module Bot
    module Forkers
      class ThreadForker < Base
        def invoke(command, args, _job_definition, dsl, delay: 0)
          Thread.new do
            sleep(delay) if delay.positive?
            @bot.handle_job(command, args, dsl.state.channel_id)
          end
        end
      end

      register_forker('thread', ThreadForker)
    end
  end
end
