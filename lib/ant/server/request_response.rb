module Ant
  module Server
    class RequestResponse
      attr_reader :params, :exception, :result
      attr_writer :exception, :result
      def initialize(request:, params:)
        @request = request
        @params = params
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
        @request.url
      end
    end
  end
end
