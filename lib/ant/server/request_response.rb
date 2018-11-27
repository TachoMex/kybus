module Ant
  module Server
    class RequestResponse
      attr_reader :params, :exception, :result, :start_timestamp
      attr_writer :exception, :result, :start_timestamp
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
