# frozen_string_literal: true

module Kybus
  module Nanorecord
    module Plugins
      class Validations < Base
        def apply(_hook_provider)
          tables.each do |t|
          end
        end
      end
      PluginProvider.register_plugin(Validations)
    end
  end
end
