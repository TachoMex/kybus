# frozen_string_literal: true

module Kybus
  module Server
    # Wraps the request and the response into an object so it is easier
    # to track monitoring logs and format the response after the endpoint was
    # executed
    class RequestResponse
      attr_accessor :exception, :result, :start_timestamp
      attr_reader :params

      def initialize(request:, params:)
        @request = request
        @params = params
        @start_timestamp = Time.now
      end

      def data
        @exception.data
      end

      def code
        @exception.code
      end

      def verb
        @request.request_method
      end

      def ip
        @request.ip
      end

      def message
        @exception.message
      end

      def path
        @request.env['PATH_INFO']
      end
    end
  end
end
