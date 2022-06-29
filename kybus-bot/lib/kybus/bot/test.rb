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
        msg = ::Kybus::Bot::Adapter::DebugMessage.new(msg, 'testing', attachments)
        @last_message = msg
        process_message(msg)
      end
    end
  end
end
