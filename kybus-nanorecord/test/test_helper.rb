# frozen_string_literal: true

require 'simplecov'
require 'minitest/autorun'
require 'minitest/mock'
require 'mocha/minitest'

SimpleCov.minimum_coverage 90
SimpleCov.start

require 'kybus/nanorecord'
