# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require './lib/kybus/bot/version'
Gem::Specification.new do |spec|
  spec.name          = 'kybus-bot'
  spec.version       = Kybus::Bot::VERSION
  spec.authors       = ['Gilberto Vargas']
  spec.email         = ['tachoguitar@gmail.com']

  spec.summary       = 'Provides a framework for building bots with ruby'
  spec.description   = 'Provides a framework for building bots with ruby'
  spec.homepage      = 'https://github.com/tachomex/kybus'
  spec.license       = 'MIT'

  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']
  spec.add_dependency 'kybus-core', '~> 0.1'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
