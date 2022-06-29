# frozen_string_literal: true

module Kybus
  module Nanorecord
    module Plugins
      class Timestamps < Base
        def apply(hook_provider)
          tables.each do |t|
            conf = config(t, 'timestamps')
            next unless conf

            hook_provider.register_hook(t, :create_table, &:timestamps)
          end
        end
      end
      PluginProvider.register_plugin(Timestamps)
    end
  end
end
