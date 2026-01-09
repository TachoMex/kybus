# frozen_string_literal: true

require 'test_helper'

class TestPluginHook < Minitest::Test
  include Kybus::Nanorecord::Plugins

  def build
    Hook.new
  end

  def test_hook
    hook = build
    hook.register_hook(:create_table, &:a)
    hook.register_hook(:create_table, &:b)
    hook.register_hook(:post_table, &:c)
    mock = {}
    mock.expects(:a).once
    mock.expects(:b).once
    mock.expects(:c).never
    hook.apply(:create_table, mock)
    refute(hook.has?(:b))
    assert(hook.has?(:create_table))
    assert(hook.has?(:post_table))
  end
end
