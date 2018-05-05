require 'httparty'
require_relative 'basic_auth'

module Ant
  module Client
    module Session
      def self.build(config)
        Base.new(config)
      end

      class Base
        include HTTParty
        include BasicAuth
        def initialize(config)
          @config = config
        end

        def configure_request(request)
          basic_auth(request, @config[:basic_auth]) if @config[:basic_auth]
        end

        def perform_request(method, endpoint, data)
          configure_request(data)
          self.class.send(method, endpoint, data)
        end
      end
    end
  end
end
