# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kybus/client/version'
Gem::Specification.new do |spec|
  spec.name          = 'kybus-client'
  spec.version       = Kybus::Client::VERSION
  spec.authors       = ['Gilberto Vargas']
  spec.email         = ['tachomexgems@gmail.com']

  spec.summary       = 'Implements a HTTP Client that can be configured a lot'
  spec.description   = 'Use this gem with a duo with the kybus-server gem'
  spec.homepage      = 'https://github.com/tachomex/kybus-client'
  spec.license       = 'MIT'

  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.add_dependency 'kybus-core', '~> 0.2'
  spec.add_dependency 'kybus-logger', '~> 0.2'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
