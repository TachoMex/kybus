module Kybus
  module Nanorecord
    class MigrationBuilder
      class MigrationField
        attr_reader :confs, :type, :name, :extra
        def initialize(name, confs, hooks)
          @confs = confs || {}
          @type = @confs['type']&.to_sym || :string
          @name = name.to_sym
          @hooks = hooks
          @extra = {
            null: @confs['not_null'],
            index: build_index,
          }.compact
        end

        def build_index
          (@confs['unique'] || @confs['index']) && { unique: @confs['unique'] }
        end
      end

      extend Kybus::DRY::ResourceInjector
      DEFAULT_MIGRATION_VERSION = 7.0

      def self.configure_migration_version(version)
        register(:migration_version, version)
      end

      attr_reader :name, :schema

      def initialize(name, schema, hook_provider)
        @name = name.tableize
        @schema = schema
        @hooks = hook_provider
      end

      def build
        base_class = ActiveRecord::Migration[self.class.unsafe_resource(:migration_version) || DEFAULT_MIGRATION_VERSION]
        fields = (schema['fields'] || {}).map { |name, confs| MigrationField.new(name, confs, @hooks) }
        table_klass = Class.new(base_class) do
          extend Kybus::DRY::ResourceInjector

          def self.precedense
            0
          end

          def change
            fields = self.class.resource(:kybus_fields)
            name = self.class.resource(:name)
            hooks = self.class.resource(:hooks)
            create_table(name, if_not_exists: true) do |t|
              fields.each { |f| t.column(f.name, f.type, **f.extra) }
              hooks.apply(:create_table, t)
            end
          end
        end
        table_klass.register(:kybus_fields, fields)
        table_klass.register(:name, name)
        table_klass.register(:hooks, @hooks)
        if @hooks.has?(:post_table)
          extra_klass = Class.new(table_klass) do
            def self.precedense
              1
            end

            def change
              hooks = self.class.superclass.resource(:hooks)
              hooks.apply(:post_table, self)
            end
          end
          [table_klass, extra_klass]
        else
          [table_klass]
        end
      end
    end
  end
end