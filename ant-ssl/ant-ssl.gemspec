# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ant/ssl/version'
Gem::Specification.new do |spec|
  spec.name          = 'ant-ssl'
  spec.version       = Ant::SSL::VERSION
  spec.authors       = ['Gilberto Vargas']
  spec.email         = ['tachoguitar@gmail.com']

  spec.summary       = 'Ant SSL tools'
  spec.description   = 'Package for creating self signed certificates for ' \
                       'development purpose'
  spec.homepage      = 'https://github.com/KueskiEngineering/ruby-ant-server'
  spec.license       = 'MIT'

  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rdoc'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'webmock'
end
