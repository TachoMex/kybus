# frozen_string_literal: true

require './test/test_helper'
require './lib/kybus/bot'
require './lib/kybus/bot/adapters/debug'

module Kybus
  module Bot
    class TestCommandCore < Minitest::Test
      def test_message_command_helpers
        msg = Adapter::DebugMessage.new('/hello world', 'testing')
        assert(msg.command?)
        assert_equal('/hello', msg.command)

        msg2 = Adapter::DebugMessage.new('hello world', 'testing')
        refute(msg2.command?)
        assert_equal('hello', msg2.command)
      end

      def test_command_definition_register_and_lookup
        definitions = Kybus::Bot::CommandDefinition.new
        definitions.register_command('/ping', [])
        assert_includes(definitions.registered_commands, '/ping')
        assert_instance_of(Kybus::Bot::Command, definitions['/ping'])
      end

      def test_command_with_param_labels
        command = Kybus::Bot::Command.new('/ask', { name: 'label' }) {}
        refute(command.ready?({}))
        assert(command.ready?({ name: 'x' }))
        assert_equal('label', command.params_ask_label('name'))
        assert_equal(1, command.params_size)
      end

      def test_adapter_from_config
        adapter = Kybus::Bot::Adapter.from_config('name' => 'debug', 'channels' => { 'testing' => [] }, 'echo' => false)
        assert_instance_of(Kybus::Bot::Adapter::Debug, adapter)
      end
    end
  end
end
