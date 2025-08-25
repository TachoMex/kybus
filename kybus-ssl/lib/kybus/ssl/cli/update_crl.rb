# frozen_string_literal: true

module Kybus
  module SSL
    module CLI
      class UpdateCRL < BaseCommand
        def run
          inv = Kybus::SSL::Inventory.load_inventory(@opts[:pki_file])
          inv.update_crl
        end
      end
    end
  end
end
