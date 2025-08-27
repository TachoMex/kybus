# frozen_string_literal: true

module Kybus
  module SSL
    module CLI
      class UpdateCRL < BaseCommand
        def run
          load_template
          update_yaml_file
          save_template

          inv = Kybus::SSL::Inventory.load_inventory(@opts[:pki_file])
          inv.update_crl
        end

        private

        def update_yaml_file
          clients = @template['certificate_descriptions']['clients']['certificates'] || []
          parents_with_revoked = clients.select { |c| c['revoked'] }.map { |c| c['parent'] }.compact.uniq
          parents_with_revoked.each { |parent| next_crl_serial(parent) } if parents_with_revoked.any?
        end
      end
    end
  end
end
