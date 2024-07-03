# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kybus/version'
Gem::Specification.new do |spec|
  spec.name          = 'kybus-server'
  spec.version       = Kybus::Server::VERSION
  spec.authors       = ['Gilberto Vargas']
  spec.email         = ['tachomexgems@gmail.com']

  spec.summary       = 'Implements Kybus format on server applications'
  spec.description   = 'This gems can be used along a server app with json' \
                       'format messages'
  spec.homepage      = 'https://github.com/tachomex/kybus'
  spec.license       = 'MIT'

  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'kybus-core'
  spec.add_runtime_dependency 'kybus-logger'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
