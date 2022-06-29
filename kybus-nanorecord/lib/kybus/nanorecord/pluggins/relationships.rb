require_relative 'base'

module Kybus
  module Nanorecord
    module Pluggins
      class Relationships < Base
        class Plugin
          def initialize(model, table, conf)
            @model = model
            @table = table
            @conf = conf
          end

          def apply_to(hook_provider, to)
            hook_provider.register_hook(@table, :create_table) do |t|
              t.column("#{to}_id".to_sym, :int)
            end

            hook_provider.register_hook(@table, :post_table) do |t|
              t.add_foreign_key(@table.to_sym, to.pluralize.to_sym)
            end

            hook_provider.register_hook(@table, :model) do |t|
              t.belongs_to(to.to_sym)
            end

            hook_provider.register_hook(to.pluralize.to_s, :model) do |t|
              t.has_many(@table.to_sym)
            end
          end

          def apply(hook_provider)
            case @conf['belongs_to']
            when String
              apply_to(hook_provider, @conf['belongs_to'])
            when Array
              @conf['belongs_to'].each { |to| apply_to(hook_provider, to) }
            end
          end
        end

        def apply(hook_provider)
          tables.each do |t|
            conf = config(t, 'belongs_to')
            next unless conf

            Plugin.new(self, t, conf).apply(hook_provider)
          end
        end
      end
      ::Kybus::Nanorecord::ModelHooks.register_plugin(Relationships)
    end
  end
end
