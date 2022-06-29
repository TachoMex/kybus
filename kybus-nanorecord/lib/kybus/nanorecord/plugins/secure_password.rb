# frozen_string_literal: true

module Kybus
  module Nanorecord
    module Plugins
      class SecurePassword < Base
        def apply(hook_provider)
          tables.each do |table|
            conf = config(table, 'safe_password')
            next unless conf

            hook_provider.register_hook(table, :create_table) do |t|
              t.string(:password_digest, null: false)
            end

            hook_provider.register_hook(table, :model, &:has_secure_password)
          end
        end
      end
      PluginProvider.register_plugin(SecurePassword)
    end
  end
end
