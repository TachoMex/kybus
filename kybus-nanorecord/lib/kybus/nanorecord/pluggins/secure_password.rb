
module Kybus
  module Nanorecord
    module Pluggins
      class SecurePassword < Base
        def apply(hook_provider)
          tables.each do |t|
            conf = config(t, 'safe_password')
            next unless conf

            hook_provider.register_hook(t, :create_table) do |t|
              t.string(:password_digest, null: false)
            end

            hook_provider.register_hook(t, :model) do |t|
              t.has_secure_password
            end
          end
        end
      end
      ::Kybus::Nanorecord::ModelHooks.register_plugin(SecurePassword)
    end
  end
end