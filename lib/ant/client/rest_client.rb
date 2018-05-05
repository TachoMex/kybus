require 'httparty'

require_relative 'session/base'
require_relative 'format/format'
require_relative 'validator'

module Ant
  module Client
    class RESTClient
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

      private

      def perform_request(method, path, data)
        log_debug('Performing request', method: method, path: path, data: data)
        result = @session.perform_request(method, "#{@endpoint}#{path}",
                                          @format.pack(data))
        unpacked = @format.unpack(result)
        @validator.validate(unpacked)
      end
    end
  end
end
