# frozen_string_literal: true

module Kybus
  module SSL
    module CLI
      class AddCA < BaseCommand
        def run
          load_template
          update_yaml_file
        end

        private

        KEYS = %i[caname name expiration key_size].freeze

        def update_yaml_file
          new_ca = opts_to_cert_config(KEYS,
                                       parent: @opts[:ca] || 'root',
                                       serial: next_serial,
                                       name: @opts[:ca_name],
                                       extensions: {
                                         basicConstraints: {
                                           details: 'CA:true, pathlen:0',
                                           critical: true
                                         }
                                       })

          @template['certificate_descriptions']['authorities']['certificates'] << new_ca

          save_template
        end
      end
    end
  end
end
