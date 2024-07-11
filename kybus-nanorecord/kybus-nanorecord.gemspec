# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kybus/nanorecord/version'
Gem::Specification.new do |spec|
  spec.name          = 'kybus-nanorecord'
  spec.version       = Kybus::Nanorecord::VERSION
  spec.authors       = ['Gilberto Vargas']
  spec.email         = ['tachomexgems@gmail.com']

  spec.summary       = 'Implements CRUD from yaml file using active record'
  spec.description   = 'Helps to create CRUD objects from a config'
  spec.homepage      = 'https://github.com/tachomex/kybus'
  spec.license       = 'MIT'

  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord'
  spec.add_dependency 'kybus-core'

  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.required_ruby_version = '~> 3.1'
end
