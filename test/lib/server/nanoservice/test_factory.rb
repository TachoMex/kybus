class TestFactory < Minitest::Test
  include DevelopmentAPI::FactoryHelpers

  ADAPTERS = %i[json sequel].freeze

  def setup
    path = 'storage/tuples/hello.json'
    File.delete(path) if File.file?(path)
    sequel_repository.connection.truncate
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

  def test_overwriting
    test_create
    ADAPTERS.each do |adapter|
      assert_raises(ObjectAlreadyExists) { factory.create(object, adapter) }
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
