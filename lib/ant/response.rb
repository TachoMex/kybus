require_relative 'format'
require_relative 'exceptions'
require 'cute_logger'

module Ant
  ##
  # This module provides a function to wrap lambdas arround grape/sinatra
  # You can mount this module as helper in your application and wrap the block
  # with the method `process_request`
  module Response
    include Format
    include Exceptions
    def process_request
      path = "#{request.request_method} #{request.url}"
      raise(AntError, 'No implementation given') unless block_given?
      result = yield
      log_info('Success Response', path: path)
      success_status(result)
    rescue AntFail => ex
      log_info('Fail Response', path: path)
      fail_status(ex.code, ex.message, ex.data)
    rescue AntError => ex
      log_warn('Error dectected on response', path: path, error: ex)
      error_status(ex.code, ex.message, ex.data)
    rescue => ex
      log_error('Unexpected error on response', path: path, error: ex,
                                                data: params)
      fatal_status
    end
  end
end
