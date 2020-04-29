# frozen_string_literal: true

require_relative 'autoconfig_test'

class TestSequel < AutoconfigTest
  def setup
    delete_file('sql.db')
  end

  def create_table(db)
    db.create_table? :tuple do
      column :key, :text, size: 40, primary_key: true
      column :value, :text, size: 40
    end
  end

  def test_sequel_connector
    data = { key: 'hello', value: 'world' }
    conf = YAML.load_file('./config/sql.yaml')
    conf = build_config(conf)
    db = conf.services('sequel', 'primary')
    assert(db)
    create_table(db)
    assert db[:tuple].insert(data)
    assert_equal(db[:tuple].first, data)
  end
end
