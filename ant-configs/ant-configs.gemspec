# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ant/configs/version'
Gem::Specification.new do |spec|
  spec.name          = 'ant-configs'
  spec.version       = Ant::Configuration::VERSION
  spec.authors       = ['Gilberto Vargas']
  spec.email         = ['tachoguitar@gmail.com']

  spec.summary       = 'Config Manager for Ant framework'
  spec.description   = 'Provides helpers for making configs easy'
  spec.homepage      = 'https://github.com/tachomex/ant'
  spec.license       = 'MIT'

  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']
  spec.add_runtime_dependency 'ant-core', '~> 0.1'

  spec.add_development_dependency 'ant-client'
  spec.add_development_dependency 'ant-logger', '~> 0.2'
  spec.add_development_dependency 'aws-sdk-s3'
  spec.add_development_dependency 'aws-sdk-sqs'
  spec.add_development_dependency 'httparty'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'mocha', '~> 1.8'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'rack-minitest', '~> 0.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rdoc', '~> 6.1'
  spec.add_development_dependency 'sequel'
  spec.add_development_dependency 'simplecov', '~> 0.16'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'webmock', '~> 3.5'
end
