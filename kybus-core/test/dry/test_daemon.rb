# frozen_string_literal: true

require_relative '../test_helper'

module Kybus
  module DRY
    # Use this for running tasks that will be looping by only sending a lambda
    class TestDaemon < Minitest::Test
      def test_it_loops_when_retry_is_enabled
        daemon = Daemon.new(1, true, true)
      end
    end
  end
end
