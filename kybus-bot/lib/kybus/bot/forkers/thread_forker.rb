# frozen_string_literal: true

module Kybus
  module Bot
    module Forkers
      class ThreadForker < Base
        def invoke(command, args, job_definition, dsl)
          Thread.new do
            dsl.instance_eval do
              @args = args
              log_info('Forking job', command:)
              instance_eval(&job_definition.block)
            end
          end
        end
      end

      register_forker('thread', ThreadForker)
    end
  end
end
