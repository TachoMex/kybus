# frozen_string_literal: true

require_relative '../test_helper'
require 'sequel'

class TestFactory < Minitest::Test
  ADAPTERS = %i[json sequel].freeze
  include Ant::Storage::Datasource
  include Ant::Storage
  include Ant::Storage::Exceptions

  # Models a single tuple as a key => value object.
  class Tuple < Ant::Storage::Datasource::Model
    def run_validations!
      raise(Ant::Exceptions::AntFail, 'nil value') if @data[:value].nil?
    end
  end

  def json_repository
    @json_repository ||= JSONRepository.new(
      'storage/tuples',
      :key,
      IDGenerators[:id]
    )
  end

  def sequel_repository
    @sequel_repository ||= begin
      db = ::Sequel.sqlite('storage/tuples.db')
      db.create_table? :tuple do
        column :key, :text, size: 40, primary_key: true
        column :value, :text, size: 40
      end
      Sequel.new(
        db[:tuple],
        :key,
        IDGenerators[:id]
      )
    end
  end

  def factory
    @factory ||= begin
      factory = Factory.new(Tuple)
      factory.register(:json, json_repository)
      factory.register('json', json_repository)
      factory.register(:sequel, sequel_repository)
      factory.register('sequel', sequel_repository)
      factory.register(:default, :json)
      factory
    end
  end

  def setup
    Dir.mkdir('storage') unless File.exist?('storage')
    path = 'storage/tuples/hello.json'
    File.delete(path) if File.file?(path)
    path = 'storage/tuples/default.json'
    File.delete(path) if File.file?(path)
    sequel_repository.connection.truncate
  end

  def object
    { key: 'hello', value: 'world' }
  end

  def fetch_tuple(adapter, key = object[:key])
    factory.get(key, adapter)
  end

  def test_create
    ADAPTERS.each do |adapter|
      factory.create(object, adapter)
      assert_equal(fetch_tuple(adapter).data, object)
    end
  end

  def test_overwriting
    test_create
    ADAPTERS.each do |adapter|
      assert_raises(ObjectAlreadyExists) { factory.create(object, adapter) }
    end
  end

  def test_store
    test_create
    ADAPTERS.each do |adapter|
      tuple = fetch_tuple(adapter)
      tuple.data[:value] = 'modified'
      tuple.store
      assert_equal(tuple.data, fetch_tuple(adapter).data)
    end
  end

  def test_not_found
    ADAPTERS.each do |adapter|
      ex = assert_raises(ObjectNotFound) { factory.get('nothing', adapter) }
      assert_equal(ex.message, 'Object nothing does not exist')
    end
  end

  def test_default_adapter
    object = { key: 'default', value: 'works' }
    factory.create(object)
    assert_equal(factory.get('default', :json).data, object)
    assert_raises(ObjectNotFound) { factory.get('default', :sequel) }
  end
end
