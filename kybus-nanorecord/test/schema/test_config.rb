# frozen_string_literal: true

require 'test_helper'

class TestConfig < Minitest::Test
  include Kybus::Nanorecord

  def build(data)
    Schema::Config.new(data, nil)
  end

  def test_parse_string
    conf = build('testing')
    assert_nil(conf.config_for('testing'))
    assert_nil(conf.config_for('not_testing'))
  end

  def test_parse_array_string
    conf = build(%w[hello testing])
    assert_equal({ 'name' => 'hello' }, conf.config_for('hello'))
    assert_equal({ 'name' => 'testing' }, conf.config_for('testing'))
    refute(conf.config_for('not_testing'))
  end

  def test_parse_hash
    conf = build([{ 'name' => 'hello', 'value' => true }, { 'name' => 'testing', 'value' => false }])
    assert(conf.config_for('hello')['value'])
    refute(conf.config_for('testing')['value'])
    assert_nil(conf.config_for('not_testing'))
  end

  def test_array_hash
    conf = build(['hello', { 'name' => 'testing' }])
    assert(conf.config_for('hello'))
    assert_equal(conf.config_for('testing'), 'name' => 'testing')
    assert_nil(conf.config_for('not_testing'))
  end
end
