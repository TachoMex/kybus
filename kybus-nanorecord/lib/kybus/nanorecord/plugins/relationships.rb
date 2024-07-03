# frozen_string_literal: true

require_relative 'base'

module Kybus
  module Nanorecord
    module Plugins
      class Relationships < Base
        class Plugin
          def initialize(model, table, conf)
            @model = model
            @table = table.tableize
            @conf = conf
          end

          def apply_to(hook_provider, to)
            hook_provider.register_hook(@table, :create_table) do |t|
              t.column(:"#{to}_id", :int)
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

          def apply_n_to_n_relationship(hook_provider, model_a, model_b)
            hook_provider.register_hook(model_a.pluralize.to_s, :model) do |t|
              t.has_many(model_b.pluralize.to_sym, through: @table.to_sym)
            end

            hook_provider.register_hook(model_b.pluralize.to_s, :model) do |t|
              t.has_many(model_a.pluralize.to_sym, through: @table.to_sym)
            end
          end

          def apply(hook_provider)
            case @conf['models']
            when String
              apply_to(hook_provider, @conf['models'])
            when Array
              @conf['models'].each { |to| apply_to(hook_provider, to) }
              apply_n_to_n_relationship(hook_provider, *@conf['models']) if @conf['models'].size == 2
            end
          end
        end

        def apply!(config, hook_provider)
          Plugin.new(model, table, config).apply(hook_provider)
        end
      end
      PluginProvider.register_plugin('belongs_to', Relationships)
    end
  end
end
