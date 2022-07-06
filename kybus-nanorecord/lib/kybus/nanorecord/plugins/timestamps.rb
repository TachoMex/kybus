# frozen_string_literal: true

module Kybus
  module Nanorecord
    module Plugins
      class Timestamps < Base
        def apply!(_config, hook_provider)
          hook_provider.register_hook(table, :create_table, &:timestamps)
        end
      end
      PluginProvider.register_plugin('timestamps', Timestamps)
    end
  end
end
