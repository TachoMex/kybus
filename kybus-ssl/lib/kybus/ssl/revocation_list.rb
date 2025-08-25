# frozen_string_literal: true

require 'openssl'
require 'fileutils'

module Kybus
  module SSL
    class RevocationList
      CRL_REASONS = { 
        'key-compromise' => 1 
        # More revocation reasons
      }.freeze

      def initialize(authorities_subinv, inventory)
        @authorities = authorities_subinv
        @inventory = inventory
      end

      def update_crl
        lifetime = @inventory.defaults['crl_lifetime'] || 30
        clients_subinv = @inventory.instance_variable_get('@clients')
        clients = clients_subinv&.instance_variable_get('@certificates') || []
        return puts 'No clients subinventory found, skipping CRL generation' if clients.empty?

        parents = clients.map { |c| c.config['parent'] }.compact.uniq
        
        parents.each do |authority_name|
          authority_crl(authority_name, clients, lifetime)
        end
      end

      private

      def authority_crl(authority_name, clients, lifetime)
        revoked_serials = clients
          .select { |c| c.config['parent'] == authority_name && c.config['revoked'] }
          .map { |c| c.config['serial'] }

        authority = (@authorities.ca(authority_name) rescue nil)
        return unless authority
        
        ca_crt = authority.config.crt_path
        ca_key = authority.config.key_path
        crl_path = File.join(File.dirname(ca_crt), "#{authority_name}.crl")

        if revoked_serials.empty?
          FileUtils.rm_f(crl_path)
          return
        end

        unless File.exist?(ca_crt) && File.exist?(ca_key)
          puts "Warning: CA files not found for #{authority_name}: expected #{ca_crt}, #{ca_key}, skipping"
          return
        end

        generate_crl(ca_crt, ca_key, crl_path, revoked_serials, lifetime)
      end

      def generate_crl(ca_crt_path, ca_key_path, crl_path, revoked_serials, lifetime)
        ca_cert = OpenSSL::X509::Certificate.new(File.read(ca_crt_path))
        ca_key = load_private_key(File.read(ca_key_path))

        crl = build_crl_base(ca_cert, lifetime)
        add_revoked_entries(crl, revoked_serials)
        add_extensions(crl, ca_cert, crl_path)
        
        crl.sign(ca_key, OpenSSL::Digest::SHA256.new)
        save_crl(crl, crl_path, revoked_serials.size)
      end

      def build_crl_base(ca_cert, lifetime)
        crl = OpenSSL::X509::CRL.new
        crl.issuer = ca_cert.subject
        crl.version = 1

        now = Time.now.utc
        crl.last_update = now
        crl.next_update = now + (lifetime * 24 * 60 * 60)
        
        crl
      end

      def add_revoked_entries(crl, revoked_serials)
        now = Time.now.utc
        
        revoked_serials.each do |serial|
          revoked = OpenSSL::X509::Revoked.new
          revoked.serial = OpenSSL::BN.new(serial.to_s)
          revoked.time = now
          revoked.add_extension(
            OpenSSL::X509::Extension.new(
              'CRLReason',
              OpenSSL::ASN1::Enumerated.new(CRL_REASONS['key-compromise']).to_der,
              false
            )
          )
          crl.add_revoked(revoked)
        end
      end

      def add_extensions(crl, ca_cert, crl_path)
        crl_number = get_next_crl_number(crl_path)
        crl.add_extension(OpenSSL::X509::Extension.new('crlNumber', OpenSSL::ASN1::Integer.new(crl_number).to_der, false))

        ski_ext = ca_cert.extensions.find { |ext| ext.oid == 'subjectKeyIdentifier' }
        aki_bytes = ski_ext ? OpenSSL::ASN1.decode(ski_ext.value_der).value : calculate_ski(ca_cert)
        raise "Could not calculate Authority Key Identifier" unless aki_bytes

        key_id = OpenSSL::ASN1::OctetString.new(aki_bytes, 0, :IMPLICIT, :CONTEXT_SPECIFIC)
        crl.add_extension(OpenSSL::X509::Extension.new('authorityKeyIdentifier', OpenSSL::ASN1::Sequence.new([key_id]).to_der, false))
      end

      def save_crl(crl, crl_path, revoked_count)
        FileUtils.mkdir_p(File.dirname(crl_path))
        File.binwrite(crl_path, crl.to_pem)
        puts "Generated CRL at #{crl_path} with #{revoked_count} revoked entries"
      end

      def get_next_crl_number(crl_path)
        return 1 unless File.exist?(crl_path)

        existing_crl = OpenSSL::X509::CRL.new(File.read(crl_path))
        crl_number_ext = existing_crl.extensions.find { |e| e.oid == 'crlNumber' }

        if crl_number_ext
          OpenSSL::ASN1.decode(crl_number_ext.value_der).value.to_i + 1
        else
          1
        end
      rescue
        1
      end

      def calculate_ski(ca_cert)
        public_key_info = OpenSSL::ASN1.decode(ca_cert.public_key.to_der)
        bit_string = public_key_info.value[1]
        actual_bits = bit_string.unused_bits == 0 ? bit_string.value : bit_string.value[1..-1]
        OpenSSL::Digest::SHA1.digest(actual_bits)
      rescue
        nil
      end

      def load_private_key(pem)
        [OpenSSL::PKey::RSA, OpenSSL::PKey::EC, OpenSSL::PKey::DSA].each do |type|
          begin
            return type.new(pem)
          rescue
            next
          end
        end
        OpenSSL::PKey.read(pem)
      end
    end
  end
end
