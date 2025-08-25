# frozen_string_literal: true

module Kybus
  module SSL
    module CLI
      class UnrevokeCertificate < BaseCommand
        def run
          load_template
          update_yaml_file
          save_template
          puts "Unrevoked certificate '#{@opts[:name]}' in #{@opts[:pki_file]}"
        end

        private

        def update_yaml_file
          clients = @template['certificate_descriptions']['clients']['certificates']
          entry   = clients.find { |c| c['name'] == @opts[:name] }
          raise "Certificate '#{@opts[:name]}' not found in clients" unless entry

          entry['revoked'] = false
        end
      end
    end
  end
end
