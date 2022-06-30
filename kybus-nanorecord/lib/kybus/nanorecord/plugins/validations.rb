# frozen_string_literal: true

module Kybus
  module Nanorecord
    module Plugins
      class Validations < Base
        def apply(_hook_provider)
          # rubocop: disable Lint/EmptyBlock
          tables.each do |t|
          end
          # rubocop: enable Lint/EmptyBlock
        end
      end
      PluginProvider.register_plugin(Validations)
    end
  end
end
