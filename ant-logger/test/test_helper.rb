# frozen_string_literal: true

require 'simplecov'
require 'minitest/test'
require 'minitest/autorun'
require 'rdoc'

SimpleCov.minimum_coverage 72
SimpleCov.start

class TestGenerateDocs < Minitest::Test
  DOC_COVERAGE = 4
  def test_run
    doc = RDoc::RDoc.new
    doc.document ['lib']

    covered = doc.stats.percent_doc

    return if covered >= DOC_COVERAGE

    puts "Doc Coverage #{covered}%/#{DOC_COVERAGE}% was not covered."
    raise('LowCoverageError')
  end
end

require 'ant/logger'
