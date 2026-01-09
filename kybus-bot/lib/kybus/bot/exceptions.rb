# frozen_string_literal: true

module Kybus
  module Bot
    # Base bot exceptions for runtime errors.
    class Base
      class BotError < StandardError; end
      class AbortError < BotError; end

      class EmptyMessageError < BotError
        def initialize
          super('Message is empty')
        end
      end
    end
  end
end
