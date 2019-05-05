# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ant/version'
Gem::Specification.new do |spec|
  spec.name          = 'ant-server'
  spec.version       = Ant::Server::VERSION
  spec.authors       = ['Gilberto Vargas']
  spec.email         = ['tachoguitar@gmail.com']

  spec.summary       = 'Implements ANT format on server applications'
  spec.description   = 'This gems can be used along a server app with json' \
                       'format messages'
  spec.homepage      = 'https://github.com/tachomex/ant'
  spec.license       = 'MIT'

  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  # TODO: Change CuteLogger to ant-logger
  spec.add_runtime_dependency 'ant-core', '~> 0.1'
  spec.add_runtime_dependency 'cute_logger', '~> 0.1'

  spec.add_development_dependency 'grape', '~> 1.2'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'mocha', '~> 1.8'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'rack-minitest', '~> 0.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rdoc', '~> 6.1'
  spec.add_development_dependency 'simplecov', '~> 0.16'
  spec.add_development_dependency 'webmock', '~> 3.5'
end
