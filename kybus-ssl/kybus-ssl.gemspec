# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kybus/ssl/version'
Gem::Specification.new do |spec|
  spec.name          = 'kybus-ssl'
  spec.version       = Kybus::SSL::VERSION
  spec.authors       = ['Gilberto Vargas']
  spec.email         = ['tachomexgems@gmail.com']

  spec.summary       = 'Kybus SSL tools'
  spec.description   = 'Package for creating self signed certificates for ' \
                       'development purpose'
  spec.homepage      = 'https://github.com/tachomex/kybus'
  spec.license       = 'MIT'

  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']
  spec.executables   = ['kybssl']

  spec.add_runtime_dependency 'optimist', '~> 3.0'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
