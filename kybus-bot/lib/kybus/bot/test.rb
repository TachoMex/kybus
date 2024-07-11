# frozen_string_literal: true

require_relative 'base'
require_relative 'adapters/debug'

module Kybus
  module Bot
    module Forkers
      class NoForker < Base
        def invoke(command, args, _job_definition, dsl, delay: 0)
          sleep(delay) if delay.positive?
          @bot.handle_job(command, args, dsl.state.channel_id)
        end
      end

      register_forker('nofork', NoForker)
    end

    class Base
      CONFIG = {
        'name' => 'test',
        'state_repository' => {
          'name' => 'json',
          'storage' => 'storage'
        },
        'pool_size' => 1,
        'provider' => {
          'name' => 'debug',
          'echo' => false,
          'channels' => { 'testing' => [] }
        },
        'forker' => {
          'provider' => 'nofork'
        }
      }.freeze

      def self.make_test_bot(extra_configs = {})
        conf = CONFIG.merge(extra_configs)
        conf['provider']['channels'] = { conf['channel_id'] => [] } if conf['channel_id']
        bot = new(conf)
        bot.instance_variable_set(:@default_channel_id, conf['provider']['channels'].keys.first)
        bot
      end

      def receives(msg, attachments = nil)
        attachments = Adapter::DebugMessage::DebugFile.new(attachments) if attachments
        msg = Adapter::DebugMessage.new(msg, @default_channel_id, attachments)
        provider.last_message = msg
        executor.process_message(msg)
      end

      def expects(method)
        executor.dsl.expects(method)
      end

      def replies(msg, attachments = nil)
        reply = @provider.channel(current_channel).last_sent_message
        raise 'NoPreviousMessageToReply' if reply.nil?

        attachments = Adapter::DebugMessage::DebugFile.new(attachments) if attachments
        msg = Adapter::DebugMessage.new(msg, @default_channel_id, attachments)
        msg.replied_message = reply
        provider.last_message = msg
        executor.process_message(msg)
      end
    end
  end
end
