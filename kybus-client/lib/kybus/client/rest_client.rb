# frozen_string_literal: true

require 'httparty'
require 'kybus/core'
require 'kybus/logger'

require_relative 'session/base'
require_relative 'format/format'
require_relative 'validator'

module Kybus
  module Client
    # HTTP client using HTTParty as support. This implementation makes it easier
    # to integrate with other backends.
    class RESTClient
      include Kybus::Logger

      def initialize(configs)
        @session = Session.build(configs)
        @config = configs
        @format = Format.build(configs)
        @endpoint = configs[:endpoint]
        @validator = Validator.build(configs)
      end

      def get(path, data = {})
        perform_request(:get, path, data)
      end

      def post(path, data = {})
        perform_request(:post, path, data)
      end

      def put(path, data = {})
        perform_request(:put, path, data)
      end

      def delete(path, data = {})
        perform_request(:delete, path, data)
      end

      def patch(path, data = {})
        perform_request(:patch, path, data)
      end

      def raw_get(path, data = {})
        perform_raw_request(:get, path, data)
      end

      def raw_post(path, data = {})
        perform_raw_request(:post, path, data)
      end

      private

      def perform_raw_request(method, path, data)
        log_debug('Performing request', method: method, path: path, data: data)
        init_time = Time.now
        uri = (path.start_with?('http') ? path : "#{@endpoint}#{path}")
        result = @session.perform_request(method, uri,
                                          @format.pack(data))
        log_info('Request perfomed',
                 path: path,
                 server: @endpoint,
                 verb: method,
                 processing_time: (Time.now - init_time).to_f * 1000)
        result
      end

      def perform_request(method, path, data)
        result = perform_raw_request(method, path, data).body
        unpacked = @format.unpack(result)
        @validator.validate(unpacked)
      end
    end
  end
end
