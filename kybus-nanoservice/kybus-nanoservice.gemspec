# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kybus/nanoservice/version'
Gem::Specification.new do |spec|
  spec.name          = 'kybus-nanoservice'
  spec.version       = Kybus::Nanoservice::VERSION
  spec.authors       = ['Gilberto Vargas']
  spec.email         = ['tachomexgems@gmail.com']

  spec.summary       = 'Implements CRUD from yaml file'
  spec.description   = 'Helps to create CRUD objects from a config'
  spec.homepage      = 'https://github.com/tachomex/kybus'
  spec.license       = 'MIT'

  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.add_dependency 'kybus-core', '~> 0.1'
  spec.add_dependency 'kybus-storage', '~> 0.1'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
