# frozen_string_literal: true

require 'simplecov'
require 'minitest/autorun'
require 'webmock/minitest'
require 'mocha/minitest'

SimpleCov.minimum_coverage 100
SimpleCov.start

require 'ant/nanoservice'
