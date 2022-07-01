# frozen_string_literal: true

require 'simplecov'
require 'minitest/autorun'
require 'rack-minitest/test'
require 'webmock/minitest'
require 'mocha/minitest'

SimpleCov.minimum_coverage 100
SimpleCov.start

require 'kybus/configs'
require 'kybus/configs/autoconfigs/aws'
require 'kybus/configs/autoconfigs/features'
require 'kybus/configs/autoconfigs/logger'
require 'kybus/configs/autoconfigs/rest_client'
require 'kybus/configs/autoconfigs/sequel'
require 'kybus/configs/autoconfigs/aws/s3'
require 'kybus/configs/autoconfigs/aws/sqs'
