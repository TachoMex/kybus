# frozen_string_literal: true

require_relative 'lib/kybus/cli/version'
Gem::Specification.new do |spec|
  spec.name          = 'kybus-cli'
  spec.version       = KYBUS_CLI_VERSION
  spec.authors       = ['Gilberto Vargas']
  spec.email         = ['tachomexgems@gmail.com']

  spec.summary       = 'CLI for managing Kybus projects'
  spec.description   = 'A CLI tool to help initialize and manage Kybus projects, ' \
                       'supporting various database adapters and configurations.'
  spec.homepage      = 'https://github.com/tachomex/kybus'
  spec.license       = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/tachomex/kybus'

  spec.files         = Dir['lib/**/*.rb'] + ['bin/kybus']
  spec.bindir        = 'bin'
  spec.executables   = ['kybus']
  spec.require_paths = ['lib']

  spec.add_dependency 'aws-sdk-cloudwatchlogs'
  spec.add_dependency 'aws-sdk-iam'
  spec.add_dependency 'aws-sdk-lambda'
  spec.add_dependency 'aws-sdk-sqs'
  spec.add_dependency 'kybus-core'
  spec.add_dependency 'rubyzip'
  spec.add_dependency 'thor'
  spec.add_dependency 'kybus-ssl'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
