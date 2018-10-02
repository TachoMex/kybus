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
          register_certificate
          register_ca
        end

        def register_certificate
          return unless @config[:client_certificate]
          cert = File.read(@config[:client_certificate])
          self.class.pkcs12(cert, @config[:client_certificate_pass])
        end

        def register_ca
          return unless @config[:ca_validate]
          puts @config[:ca_validate]
          self.class.ssl_ca_file(@config[:ca_validate])
        end

        def configure_request(request)
          basic_auth(request, @config[:basic_auth]) if @config[:basic_auth]
          request[:verify] = @config[:verify] if @config.key?(:verify)

        end

        def perform_request(method, endpoint, data)
          configure_request(data)
          self.class.send(method, endpoint, data)
        end
      end
    end
  end
end
