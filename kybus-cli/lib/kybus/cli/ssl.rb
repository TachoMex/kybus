require 'thor'

require 'kybus/ssl'
require 'kybus/ssl/cli'


module Kybus
  class CLI < Thor
    class SSL < Thor
      desc 'init', 'initialize new PKI file'
      class_option :path, alias: :P ,type: :string, desc: 'Set storage path', required: true
      method_option :force, type: :boolean, desc: 'Overwrites previous file', required: false, default: false
      method_option :key_size, alias: :s, desc: 'RSA Key Size', required: true, type: :numeric
      method_option :team, alias: :T, desc: 'Organization Unit', required: true
      method_option :country, alias: :C, desc: 'Country', required: true
      method_option :city , alias: :c, desc: 'City', required: true
      method_option :state , alias: :S, desc: 'State', required: true


      def init
        Kybus::SSL::CLI::Init.new(options.merge(pki_file: "#{options[:path]}/pki.yaml")).run
      end

      desc 'add-ca', 'Add a new CA to inventory'
      method_option :ca_name, type: :string, desc: 'CA Name', required: true
      method_option :key_size, alias: :s, desc: 'RSA Key Size', required: true, type: :numeric
      method_option :expiration, alias: :X, desc: 'Expiration in Years', required: false, type: :numeric
      method_option :ca, type: :string, desc: 'CA Parent Name, default: root', required: false, default: 'root'
      method_option :team, alias: :T, desc: 'Organization Unit', required: false
      method_option :country, alias: :C, desc: 'Country', required: false
      method_option :city , alias: :c, desc: 'City', required: false
      method_option :state , alias: :S, desc: 'State', required: false


      def add_ca
        Kybus::SSL::CLI::AddCA.new(options.merge(pki_file: "#{options[:path]}/pki.yaml")).run
      end

      desc 'add-certificate', 'Add new certificate to inventory'
      method_option :expiration, alias: :X, desc: 'Expiration in Years', required: false, type: :numeric
      method_option :ca
      method_option :key_size, alias: :s, desc: 'RSA Key Size', required: false, type: :numeric
      method_option :name, required: true
      method_option :email, alias: :E, desc: 'E-Mail', required: false
      method_option :team, alias: :T, desc: 'Organization Unit', required: false
      method_option :country, alias: :C, desc: 'Country', required: false
      method_option :city , alias: :c, desc: 'City', required: false
      method_option :state , alias: :S, desc: 'State', required: false

      def add_certificate
        Kybus::SSL::CLI::AddCertificate.new(options.merge(pki_file: "#{options[:path]}/pki.yaml")).run
      end

      desc 'update-crl', 'Generate the CRL'
      method_option :path, type: :string, desc: 'PKI root path', required: true

      def update_crl
        Kybus::SSL::CLI::UpdateCRL.new(options.merge(pki_file: "#{options[:path]}/pki.yaml")).run
      end

      desc 'revoke-certificate', 'Mark a client certificate as revoked'
      method_option :name, type: :string, desc: 'Certificate name', required: true
      method_option :path, type: :string, desc: 'PKI root path', required: true

      def revoke_certificate
        Kybus::SSL::CLI::RevokeCertificate.new(options.merge(pki_file: "#{options[:path]}/pki.yaml")).run
      end

      desc 'unrevoke-certificate', 'Unmark a client certificate as revoked'
      method_option :name, type: :string, desc: 'Certificate name', required: true
      method_option :path, type: :string, desc: 'PKI root path', required: true

      def unrevoke_certificate
        Kybus::SSL::CLI::UnrevokeCertificate.new(options.merge(pki_file: "#{options[:path]}/pki.yaml")).run
      end

      desc 'build', 'Builds the certificates listed in the PKI file'

      def build
        Kybus::SSL::CLI::Build.new(options.merge(pki_file: "#{options[:path]}/pki.yaml")).run
      end
    end
  end
end
