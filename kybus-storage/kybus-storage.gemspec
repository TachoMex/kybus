# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kybus/version'
Gem::Specification.new do |spec|
  spec.name          = 'kybus-storage'
  spec.version       = Kybus::Storage::VERSION
  spec.authors       = ['Gilberto Vargas']
  spec.email         = ['tachomexgems@gmail.com']

  spec.summary       = 'Implements storage modules for kybus framework'
  spec.description   = <<-DESC
    This module helps to design persistance modules that are very configurable
    about where and how to store data.
  DESC

  spec.homepage      = 'https://github.com/tachomex/kybus'
  spec.license       = 'MIT'

  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.metadata['rubygems_mfa_required'] = 'true'
end
