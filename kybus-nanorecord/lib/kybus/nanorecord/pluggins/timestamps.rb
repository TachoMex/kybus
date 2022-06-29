
module Kybus
  module Nanorecord
    module Pluggins
      class Timestamps < Base
        def apply(hook_provider)
          tables.each do |t|
            conf = config(t, 'timestamps')
            next unless conf

            hook_provider.register_hook(t, :create_table) do |t|
              t.timestamps
            end
          end
        end
      end
      ::Kybus::Nanorecord::ModelHooks.register_plugin(Timestamps)
    end
  end
end