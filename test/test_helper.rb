require 'simplecov'
require 'minitest/test'
require 'minitest/autorun'
require 'rack-minitest/test'
require 'rdoc'
require 'webmock/minitest'

SimpleCov.minimum_coverage 100
SimpleCov.start

class TestGenerateDocs < Minitest::Test
  DOC_COVERAGE = 90
  def test_run
    doc = RDoc::RDoc.new
    doc.document ['lib']

    covered = doc.stats.percent_doc

    return if covered >= DOC_COVERAGE
    puts "Doc Coverage #{covered}%/#{DOC_COVERAGE}% was not covered."
    raise('LowCoverageError')
  end
end

require './development_api'
