# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kybus/version'
Gem::Specification.new do |spec|
  spec.name          = 'kybus-storage'
  spec.version       = Kybus::Storage::VERSION
  spec.authors       = ['Gilberto Vargas']
  spec.email         = ['tachoguitar@gmail.com']

  spec.summary       = 'Implements storage modules for kybus framework'
  spec.description   = <<-EOF
    This module helps to design persistance modules that are very configurable
    about where and how to store data.
  EOF

  spec.homepage      = 'https://github.com/tachomex/kybus'
  spec.license       = 'MIT'

  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'kybus-core', '~> 0.1'
  spec.add_development_dependency 'minitest', '~> 5.11'
  spec.add_development_dependency 'mocha', '~> 1.8'
  spec.add_development_dependency 'pry', '~> 0.12'
  spec.add_development_dependency 'rack-minitest', '~> 0.0'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rdoc', '~> 6.1'
  spec.add_development_dependency 'sequel', '~> 5.20'
  spec.add_development_dependency 'simplecov', '~> 0.16'
  spec.add_development_dependency 'sqlite3', '~> 1.4'
  spec.add_development_dependency 'webmock', '~> 3.5'
end
