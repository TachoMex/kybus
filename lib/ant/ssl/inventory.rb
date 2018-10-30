require_relative 'configuration'
require_relative 'certificate'
require_relative 'revocation_list'

require 'fileutils'

module Ant
  module SSL
    class Inventory
      attr_reader :defaults

      def initialize(defaults, auth, clients, servers)
        @defaults = defaults
        @authorities = SubInventory.new(auth, self)
        @clients = SubInventory.new(clients, self)
        @servers = SubInventory.new(servers, self)
      end

      def create_certificates!
        validate_inventories!
        create_directory!
        [@authorities, @clients, @servers].each(&:create_certificates!)
      end

      def validate_inventories!
        true
      end

      def create_directory!
        FileUtils.mkdir_p(@defaults['saving_directory'])
      end

      def ca(name)
        @authorities.ca(name)
      end
    end

    class SubInventory
      def initialize(configs, inventory)
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

      def create_certificates!
        @certificates.each(&:create!)
      end

      def ca(name)
        @certificates.find { |cert| cert.ca_name == name }
      end
    end
  end
end
