# frozen_string_literal: true

require_relative 'configuration'
require_relative 'certificate'
require_relative 'revocation_list'
require 'yaml'

require 'fileutils'

module Kybus
  module SSL
    # This provides a full inventory of PKI.
    # It is composed of:
    # - Authorities
    # - Clients
    # - Servers
    class Inventory
      attr_reader :defaults

      def initialize(defaults, auth, clients, servers)
        @defaults = defaults
        @authorities = SubInventory.new(auth, self)
        @clients = SubInventory.new(clients, self)
        @servers = SubInventory.new(servers, self)
      end

      def self.load_inventory(path)
        inventory = YAML.load_file(path)
        data = inventory['certificate_descriptions']
        new(data['defaults'], data['authorities'], data['clients'], data['servers'])
      end

      def create_certificates!
        validate_inventories!
        create_directory!
        [@authorities, @clients, @servers].each(&:create_certificates!)
      end

      def ca_cert_chain(parent)
        @authorities.ca_cert_chain(parent)
      end

      # TODO: Implement validation of inventories
      def validate_inventories!
        true
      end

      def update_crl
        @authorities.update_crl
      end

      def create_directory!
        FileUtils.mkdir_p(@defaults['saving_directory'])
      end

      def ca(name)
        @authorities.ca(name)
      end
    end

    # Implements a single inventory. It creates certificates using similar
    # configurations.
    class SubInventory
      def initialize(configs, inventory)
        raise 'Nil config' if configs.nil?

        defaults = configs['defaults']
        @parent = inventory
        @certificates = configs['certificates'].map do |cert|
          configuration = Configuration.new(
            inventory.defaults,
            defaults,
            cert
          )
          Certificate.new(configuration, inventory)
        end
      end

      def ca_cert_chain(name)
        chain = []
        cert = ca(name)

        while cert && cert.ca_name != 'root'
          puts cert.ca_name
          chain << cert.cert
          cert = @certificates.find { |c| c.ca_name == cert.config['parent'] }
        end
        chain
      end

      def update_crl
        Kybus::SSL::RevocationList.new(self, @parent).update_crl
      end

      def create_certificates!
        @certificates.each(&:create!)
      end

      def ca(name)
        ca = @certificates.find { |cert| cert.ca_name == name }
        raise "CA #{name} not found" if ca.nil?

        ca
      end
    end
  end
end
