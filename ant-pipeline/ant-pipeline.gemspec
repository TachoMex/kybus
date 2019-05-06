# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ant/pipeline/version'
Gem::Specification.new do |spec|
  spec.name          = 'ant-pipeline'
  spec.version       = Ant::Pipeline::VERSION
  spec.authors       = ['Gilberto Vargas']
  spec.email         = ['tachoguitar@gmail.com']

  spec.summary       = 'Implements ANT format on server applications'
  spec.description   = 'This gems can be used along a server app with json' \
                       'format messages'
  spec.homepage      = 'https://github.com/tachomex/ant-pipeline'
  spec.license       = 'MIT'

  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']
end
