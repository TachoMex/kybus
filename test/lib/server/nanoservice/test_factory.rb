require 'sequel'

class TestFactory < Minitest::Test
  include Ant::Server::Nanoservice
  include Datasource
  include Exceptions

  ADAPTERS = %i[json sequel].freeze

  class Tuple < Model
    def run_validations!; end
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
      db.drop_table(:tuple) if db.table_exists?(:tuple)
      db.create_table :tuple do
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
      factory.register(:sequel, sequel_repository)
      factory.register(:default, :sequel)
      factory
    end
  end

  def object
    { key: 'hello', value: 'world' }
  end

  def test_create
    ADAPTERS.each do |adapter|
      factory.create(object, adapter)
      assert_equal(factory.get(object[:key], adapter).data, object)
    end
  end

  def test_store
    test_create
    ADAPTERS.each do |adapter|
      tuple = factory.get(object[:key], adapter)
      tuple.data[:value] = 'modified'
      tuple.store
      assert_equal(tuple.data, factory.get(object[:key], adapter).data)
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
    assert_equal(factory.get('default', :sequel).data, object)
    assert_raises(ObjectNotFound) { factory.get('default', :json) }
  end
end
