# frozen_string_literal: true

require 'simplecov'
require 'minitest/autorun'
require 'rack-minitest/test'
require 'webmock/minitest'
require 'mocha/minitest'

SimpleCov.minimum_coverage 100
SimpleCov.start

require 'ant/configs'
require 'ant/configs/autoconfigs/aws'
require 'ant/configs/autoconfigs/features'
require 'ant/configs/autoconfigs/logger'
require 'ant/configs/autoconfigs/nanoservice'
require 'ant/configs/autoconfigs/rest_client'
require 'ant/configs/autoconfigs/sequel'
require 'ant/configs/autoconfigs/aws/s3'
require 'ant/configs/autoconfigs/aws/sqs'
