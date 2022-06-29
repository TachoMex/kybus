# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kybus/logger/version'
Gem::Specification.new do |spec|
  spec.name          = 'kybus-logger'
  spec.version       = Kybus::Logger::VERSION
  spec.authors       = ['Gilberto Vargas']
  spec.email         = ['tachoguitar@gmail.com']

  spec.summary       = 'Implements a kybus-logger with a format based on ' \
                       'cute_logger'
  spec.description   = 'Make logs formatter and handling easier'
  spec.homepage      = 'https://github.com/tachomex/kybus'
  spec.license       = 'MIT'

  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'kybus-core', '~> 0.1'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rdoc'
  spec.add_development_dependency 'simplecov'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
