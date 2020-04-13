# frozen_string_literal: true

require 'simplecov'
require 'minitest/test'
require 'minitest/autorun'
require 'rack-minitest/test'
require 'rdoc'
require 'webmock/minitest'
require 'mocha/minitest'
require 'sequel'

SimpleCov.minimum_coverage 100
SimpleCov.start

class TestGenerateDocs < Minitest::Test
  DOC_COVERAGE = 89
  def test_run
    doc = RDoc::RDoc.new
    doc.document ['lib']

    covered = doc.stats.percent_doc

    return if covered >= DOC_COVERAGE

    puts "Doc Coverage #{covered}%/#{DOC_COVERAGE}% was not covered."
    raise('LowCoverageError')
  end
end

CONFIG = {
  'name' => 'antbot',
  'state_repository' => {
    'name' => 'json',
    'storage' => 'storage'
  },
  'pool_size' => 1,
  'provider' => {
    'name' => 'debug',
    'echo' => false,
    'channels' => {
      'a' => [
        '/remindme',
        'to get eggs',
        '2019-03-11 12:00 everyday'
      ],
      'b' => [
        '/remindme',
        'to take the pills',
        '2019-03-11 23:00 everyday'
      ]
    }
  }
}.freeze

require 'ant/bot'
require 'ant/bot/migrator'
require 'ant/bot/testing'
require 'ant/bot/adapters/debug'
require 'ant/bot/adapters/telegram'
