# frozen_string_literal: true

module Kybus
  module SSL
    module CLI
      class AddCertificate < BaseCommand
        def run
          load_template
          update_yaml_file
        end

        private

        KEYS = %i[name expiration key_size team country city state email].freeze

        def update_yaml_file
          new_certificate = opts_to_cert_config(KEYS, {
                                                  parent: @opts[:ca],
                                                  serial: next_serial,
                                                  organization: @opts[:org],
                                                  revoked: false
                                                })

          @template['certificate_descriptions']['clients']['certificates'] << new_certificate

          save_template
        end
      end
    end
  end
end
