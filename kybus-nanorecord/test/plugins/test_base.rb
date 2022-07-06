# frozen_string_literal: true

require 'test_helper'

class TestPluginBase < Minitest::Test
  include Kybus::Nanorecord::Plugins

  def setup
    schema = Kybus::Nanorecord.load_schema!('./nanorecord.yml')
    @base = Base.new(schema.models['users'])
  end

  def test_table
    assert_equal('users', @base.table)
  end
end
