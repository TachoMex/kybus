# frozen_string_literal: true

require 'kybus/core'
require 'json'

require_relative 'logger/config'
require_relative 'logger/format'
require_relative 'logger/log_methods'

module Kybus
  module Logger
    include LogMethods
  end
end
