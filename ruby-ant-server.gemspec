lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ant/version'

Gem::Specification.new do |spec|
  spec.name          = 'ruby-ant-server'
  spec.version       = Ant::VERSION
  spec.authors       = ['Gilberto Vargas']
  spec.email         = ['tachoguitar@gmail.com']

  spec.summary       = 'Implements ANT format on server applications'
  spec.description   = 'This gems can be used along a server app with json' \
                       'format messages'
  spec.homepage      = 'https://github.com/KueskiEngineering/ruby-ant-server'
  spec.license       = 'MIT'

  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'cute_logger', '~> 0.1'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'grape'
  spec.add_development_dependency 'httparty'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'puma'
  spec.add_development_dependency 'rack'
  spec.add_development_dependency 'rack-minitest'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rdoc'
  spec.add_development_dependency 'sequel'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'webmock'
end
