# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kybus/ssl/version'
Gem::Specification.new do |spec|
  spec.name          = 'kybus-ssl'
  spec.version       = Kybus::SSL::VERSION
  spec.authors       = ['Gilberto Vargas']
  spec.email         = ['tachoguitar@gmail.com']

  spec.summary       = 'Kybus SSL tools'
  spec.description   = 'Package for creating self signed certificates for ' \
                       'development purpose'
  spec.homepage      = 'https://github.com/KueskiEngineering/ruby-kybus-server'
  spec.license       = 'MIT'

  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'minitest', '~> 5.11'
  spec.add_development_dependency 'pry', '~> 0.12'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rdoc', '~> 6.1'
  spec.add_development_dependency 'simplecov', '~> 0.16'
  spec.add_development_dependency 'webmock', '~> 3.5'
end
