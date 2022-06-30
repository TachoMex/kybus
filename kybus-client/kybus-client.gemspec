# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kybus/client/version'
Gem::Specification.new do |spec|
  spec.name          = 'kybus-client'
  spec.version       = Kybus::Client::VERSION
  spec.authors       = ['Gilberto Vargas']
  spec.email         = ['tachoguitar@gmail.com']

  spec.summary       = 'Implements a HTTP Client that can be configured a lot'
  spec.description   = 'Use this gem with a duo with the kybus-server gem'
  spec.homepage      = 'https://github.com/tachomex/kybus-client'
  spec.license       = 'MIT'

  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'kybus-core', '~> 0.1'
  spec.add_runtime_dependency 'kybus-logger', '~> 0.1'
  spec.add_development_dependency 'httparty'

  spec.add_development_dependency 'minitest', '~> 5.11'
  spec.add_development_dependency 'mocha', '~> 1.8'
  spec.add_development_dependency 'pry', '~> 0.12'
  spec.add_development_dependency 'rack-minitest', '~> 0.0'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rdoc', '~> 6.1'
  spec.add_development_dependency 'simplecov', '~> 0.16'
  spec.add_development_dependency 'webmock', '~> 3.5'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
