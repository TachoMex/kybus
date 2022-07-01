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
          'echo' => true,
          'channels' => { 'testing' => [] }
        }
      }.freeze

      def self.make_test_bot
        new(CONFIG)
      end

      def receives(msg, attachments = nil)
        attachments = Adapter::DebugMessage::DebugFile.new(attachments) if attachments
        msg = Adapter::DebugMessage.new(msg, 'testing', attachments)
        @last_message = msg
        @commands.process_message(msg)
      end

      def expects(method)
        @commands.dsl.expects(method)
      end
    end
  end
end
