# frozen_string_literal: true

require 'simplecov'
require 'minitest/test'
require 'minitest/autorun'
require 'rack-minitest/test'
require 'webmock/minitest'
require 'mocha/minitest'

SimpleCov.minimum_coverage 90
SimpleCov.start

require 'kybus/storage'
