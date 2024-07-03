# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kybus/version'
Gem::Specification.new do |spec|
  spec.name          = 'kybus-core'
  spec.version       = Kybus::Core::VERSION
  spec.authors       = ['Gilberto Vargas']
  spec.email         = ['tachomexgems@gmail.com']

  spec.summary       = 'Kybus framework core functionality'
  spec.description   =  <<-DESC
    Kybus::Core will be used across all the kybus gems. Provides the most basic
    functionality or what might be used along with more than one gem.
    Currently this only exposes the basic exceptions and the DRY patterns.
  DESC
  spec.homepage      = 'https://github.com/tachomex/kybus'
  spec.license       = 'MIT'

  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.metadata['rubygems_mfa_required'] = 'true'
end
