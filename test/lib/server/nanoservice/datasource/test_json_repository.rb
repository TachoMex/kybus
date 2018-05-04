class TestJSONRepository < Minitest::Test
  include Ant::Server::Nanoservice::Datasource
  include Exceptions

  PATH = 'storage/tuples/hello.json'.freeze

  def repository
    @repository ||= JSONRepository.new(
      'storage/tuples',
      :key,
      IDGenerators[:id]
    )
  end

  def assert_file(path, object)
    assert(File.file?(path))
    assert_equal(object.to_json, File.read(path))
  end

  def object
    { key: 'hello', value: 'world' }
  end

  def test_create
    repository.create(object)
    assert_file(PATH, key: 'hello')
  end

  def test_store
    test_create
    repository.store(object)
    assert_file(PATH, object)
  end

  def test_get
    test_store
    loaded = repository.get('hello')
    assert_equal(object, loaded)
  end

  def test_not_found
    ex = assert_raises(ObjectNotFound) { repository.get('nothing') }
    assert_equal(ex.message, 'Object nothing does not exist')
  end
end
