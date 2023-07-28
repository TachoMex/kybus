# frozen_string_literal: true

require_relative 'base'
require_relative 'adapters/debug'

module Kybus
  module Bot
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
        log_info('Received message', channel: @default_channel_id, msg: msg.raw_message)
        provider.last_message = msg
        executor.process_message(msg)
      end

      def expects(method)
        executor.dsl.expects(method)
      end
    end
  end
end
