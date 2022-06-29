module Kybus
  module Nanorecord
    module Pluggins
      class Validations < Base
        def apply(hook_provider)
          tables.each do |t|
          end
        end
      end
      ::Kybus::Nanorecord::ModelHooks.register_plugin(Validations)
    end
  end
end