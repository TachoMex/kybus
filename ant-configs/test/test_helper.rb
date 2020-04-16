# frozen_string_literal: true

require 'simplecov'
require 'minitest/test'
require 'minitest/autorun'
require 'rack-minitest/test'
require 'rdoc'
require 'webmock/minitest'
require 'mocha/minitest'

SimpleCov.minimum_coverage 99
SimpleCov.start

class TestGenerateDocs < Minitest::Test
  DOC_COVERAGE = 67
  def test_run
    doc = RDoc::RDoc.new
    doc.document ['lib']

    covered = doc.stats.percent_doc

    return if covered >= DOC_COVERAGE

    puts "Doc Coverage #{covered}%/#{DOC_COVERAGE}% was not covered."
    raise('LowCoverageError')
  end
end

require 'ant/configs'
require 'ant/configs/autoconfigs/aws'
require 'ant/configs/autoconfigs/features'
require 'ant/configs/autoconfigs/logger'
require 'ant/configs/autoconfigs/nanoservice'
require 'ant/configs/autoconfigs/rest_client'
require 'ant/configs/autoconfigs/sequel'
require 'ant/configs/autoconfigs/aws/s3'
require 'ant/configs/autoconfigs/aws/sqs'
