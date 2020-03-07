# frozen_string_literal: true

require 'simplecov'
require 'minitest/test'
require 'minitest/autorun'
require 'rdoc'
require 'webmock/minitest'
require 'mocha/minitest'

SimpleCov.minimum_coverage 52
SimpleCov.start

class TestGenerateDocs < Minitest::Test
  DOC_COVERAGE = 15
  def test_run
    doc = RDoc::RDoc.new
    doc.document ['lib']

    covered = doc.stats.percent_doc

    return if covered >= DOC_COVERAGE

    puts "Doc Coverage #{covered}%/#{DOC_COVERAGE}% was not covered."
    raise('LowCoverageError')
  end
end

require 'ant/nanoservice'
