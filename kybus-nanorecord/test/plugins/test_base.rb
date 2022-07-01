# frozen_string_literal: true

require 'test_helper'

class TestPluginBase < Minitest::Test
  include Kybus::Nanorecord::Plugins

  def setup
    schema = Kybus::Nanorecord.load_schema!('./nanorecord.yml')
    @base = Base.new(schema)
  end

  def test_tables
    assert_equal(@base.tables, %w[articles users categories article_classifications])
  end

  def test_table_fetch
    table = @base.table('users')
    assert_equal(table.name, 'User')
    assert_equal(table.fields.size, 4)
    @base.append_field('users', 'age', 'type' => 'int')
    refute_nil(@base.config('users', 'safe_password'))
  end
end
