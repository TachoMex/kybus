module Kybus
  module SSL
    module CLI
      class Build < BaseCommand
        def run
          inv = Kybus::SSL::Inventory.load_inventory(@opts[:pki_file])
          inv.create_certificates!
        end
      end
    end
  end
end