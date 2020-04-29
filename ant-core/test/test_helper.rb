# frozen_string_literal: true

require 'simplecov'
require 'minitest/autorun'
require 'rack-minitest/test'
require 'webmock/minitest'
require 'mocha/minitest'

SimpleCov.minimum_coverage 100
SimpleCov.start


require './lib/ant/core'
