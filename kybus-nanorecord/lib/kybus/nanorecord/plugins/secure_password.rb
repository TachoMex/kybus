# frozen_string_literal: true

module Kybus
  module Nanorecord
    module Plugins
      class SecurePassword < Base
        def apply!(_config, hook_provider)
          hook_provider.register_hook(table, :create_table) do |t|
            t.string(:password_digest, null: false)
          end

          hook_provider.register_hook(table, :model, &:has_secure_password)
        end
      end

      PluginProvider.register_plugin('safe_password', SecurePassword)
    end
  end
end
