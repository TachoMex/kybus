# frozen_string_literal: true

require 'test_helper'

class TestSchema < Minitest::Test
  def setup
    @file = './nanorecord.yml'
    @db_file = './test.sqlite'
    File.delete(@db_file) if File.file?(@db_file)
    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: 'test.sqlite'
    )
    @schema = Kybus::Nanorecord.load_schema!(@file)
  end

  def raw_connection
    SQLite3::Database.open(@db_file)
  end

  def test_load_file
    assert(@schema)
  end

  def test_allow_to_change_migration_version
    Kybus::Nanorecord::Schema::ModelMigration.configure_migration_version(6.0)
    assert_equal(6.0, Kybus::Nanorecord::Schema::ModelMigration.resource(:migration_version))
  end

  def test_migrations
    @schema.run_migrations!
    info = raw_connection.table_info('users')
    assert_equal(info[0]['name'], 'id')
    assert_equal(info[1]['name'], 'username')
    assert_equal(info[2]['name'], 'borndate')
    assert_equal(info[7]['name'], 'updated_at')
  end

  def test_class_creation
    test_migrations
    @schema.build_classes!
    assert(User)
    user = User.create(username: 'hello', borndate: Date.new(1, 1, 1), email: 'user@mail.me',
                       mobile: '+11932122283', password: 'secret')
    assert(user.password_digest != 'secret')
    user.articles << Article.create(title: 'Nice article', description: 'hello')
    assert_equal(user.articles.all.size, 1)
  end
end
