# frozen_string_literal: true

require 'simplecov'
require 'minitest/autorun'
require 'rack-minitest/test'
require 'webmock/minitest'
require 'mocha/minitest'

SimpleCov.minimum_coverage 90
SimpleCov.start

require 'kybus/storage'

module TestHelpers
  def delete_storage(path)
    File.delete(path) if File.file?(path)
  end
end
