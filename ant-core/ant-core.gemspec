# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ant/version'
Gem::Specification.new do |spec|
  spec.name          = 'ant-core'
  spec.version       = Ant::Core::VERSION
  spec.authors       = ['Gilberto Vargas']
  spec.email         = ['tachoguitar@gmail.com']

  spec.summary       = 'Ant framework core functionality'
  spec.description   = spec.description = <<-EOF
    Ant::Core will be used across all the ant gems. Provides the most basic
    functionality or what might be used along with more than one gem.
    Currently this only exposes the basic exceptions and the DRY patterns.
  EOF
  spec.homepage      = 'https://github.com/tachomex/ant'
  spec.license       = 'MIT'

  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'ant-logger', '~> 0.1'
  spec.add_development_dependency 'minitest', '~> 5.11'
  spec.add_development_dependency 'mocha', '~> 1.8'
  spec.add_development_dependency 'pry', '~> 0.12'
  spec.add_development_dependency 'rack-minitest', '~> 0.0'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rdoc', '~> 6.1'
  spec.add_development_dependency 'simplecov', '~> 0.16'
  spec.add_development_dependency 'webmock', '~> 3.5'
end
