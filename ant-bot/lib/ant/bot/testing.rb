# frozen_string_literal: true

require_relative 'adapters/debug'
require_relative 'base'
module Ant
  module Bot
    class NonDebugAdapterInTesting < StandardError
    end

    # Base class for bot implementation. It wraps the threads execution, the
    # provider and the state storage inside an object.
    class Base
      include Ant::Bot::Adapter
      def stub_channels(messages)
        raise(NonDebugAdapterInTesting) unless @provider.is_a?(Debug)

        @provider = Debug.new('channels' => messages)
      end

      def run_test
        run
      rescue Debug::NoMoreMessageException
        true
      end
    end
  end
end
