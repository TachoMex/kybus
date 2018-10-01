require 'openssl'

module Ant
  module SSL
    class Certificate
      attr_reader :cert, :key

      def initialize(config, inventory)
        @config = config
        @inventory = inventory
        @key = OpenSSL::PKey::RSA.new(@config['key_size'])
        @cert = OpenSSL::X509::Certificate.new
        @cert.public_key = @key.public_key
        @extensions = OpenSSL::X509::ExtensionFactory.new
        @extensions.subject_certificate = @cert
      end

      def create!
        # return if File.file?(@config.key_path)
        @ca = @inventory.ca(@config['parent'])
        configure_details!
        configure_extensions!
        sign!
        save!
      end

      def configure_details!
        @config.configure_cert_details!(@cert)
      end

      def configure_extensions!
        @extensions.issuer_certificate = @ca.cert
        @config.configure_extensions!(@cert, @extensions)
      end

      def sign!
        @cert.issuer = @ca.cert.subject
        @cert.sign(@ca.key, OpenSSL::Digest::SHA256.new)
      end

      def save!
        File.write(@config.key_path, @key.to_s)
        File.write(@config.crt_path, @cert.to_s)
      end

      def ca_name
        @config['ca']
      end
    end
  end
end
