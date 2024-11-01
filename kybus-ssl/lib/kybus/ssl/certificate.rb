# frozen_string_literal: true

require 'openssl'
require 'securerandom'

module Kybus
  module SSL
    # Stores a X509 certificate.
    class Certificate
      attr_reader :cert, :key, :config

      def initialize(config, inventory)
        @config = config
        @inventory = inventory

        if File.file?(@config.key_path) && File.file?(@config.crt_path)
          load_key!
        else
          create_key!
        end
      end

      def create_key!
        @key = OpenSSL::PKey::RSA.new(@config['key_size'])
        @cert = OpenSSL::X509::Certificate.new
        @cert.public_key = @key.public_key
        @extensions = OpenSSL::X509::ExtensionFactory.new
        @extensions.subject_certificate = @cert
      end

      def load_key!
        @key = OpenSSL::PKey::RSA.new(File.read(@config.key_path))
        @cert = OpenSSL::X509::Certificate.new(File.read(@config.crt_path))
      end

      def create!
        if File.file?(@config.key_path) && File.file?(@config.crt_path)
          return puts "Certificate already exists #{@config.key_path} #{@cert.subject}"
        end

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
        @cert.sign(@ca.key, OpenSSL::Digest.new('SHA256'))
      end

      def save!
        puts "Saving certificate #{@cert.subject}"
        File.write(@config.key_path, @key.to_s)
        File.write(@config.crt_path, @cert.to_s)
        export_to_pfx!
      end

      def export_to_pfx!
        passphrase = SecureRandom.alphanumeric(15)
        chain = [@cert] + @inventory.ca_cert_chain(@config['parent'])
        pkcs12 = OpenSSL::PKCS12.create(passphrase, @config['email'] || @config['name'], @key, @cert, chain)
        File.write(@config.pfx_path, pkcs12.to_der)
        puts "PFX certificate saved with passphrase: #{passphrase}"
      end

      def ca_name
        @config['ca']
      end
    end
  end
end
