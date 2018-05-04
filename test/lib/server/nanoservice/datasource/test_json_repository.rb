require 'sequel'

class TestModel < Minitest::Test
  include Ant::Server::Nanoservice::Datasource
  include Exceptions

  ADAPTERS = %i[json sequel].freeze

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

  def repositories
    @repositories ||= {
      json: json_repository,
      sequel: sequel_repository
    }
  end

  def object
    { key: 'hello', value: 'world' }
  end

  def test_create
    ADAPTERS.each do |adapter|
      repository = repositories[adapter]
      repository.create(object)
      assert_equal(repository.get(object[:key]), object)
    end
  end

  def test_store
    test_create
    ADAPTERS.each do |adapter|
      repository = repositories[adapter]
      repository.store(object)
      assert_equal(repository.get(object[:key]), object)
    end
  end

  def test_get
    test_store
    ADAPTERS.each do |adapter|
      repository = repositories[adapter]
      loaded = repository.get('hello')
      assert_equal(object, loaded)
    end
  end

  def test_not_found
    ADAPTERS.each do |adapter|
      repository = repositories[adapter]
      ex = assert_raises(ObjectNotFound) { repository.get('nothing') }
      assert_equal(ex.message, 'Object nothing does not exist')
    end
  end
end
