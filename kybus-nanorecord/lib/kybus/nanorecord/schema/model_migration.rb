# frozen_string_literal: true

module Kybus
  module Nanorecord
    class Schema
      class ModelMigration
        extend Kybus::DRY::ResourceInjector
        DEFAULT_MIGRATION_VERSION = 7.0

        def self.configure_migration_version(version)
          register(:migration_version, version)
        end

        attr_reader :name, :fields

        attr_writer :hooks

        def initialize(model_name, fields, _configs)
          @name = model_name.tableize
          @fields = fields
          @migrations = []
        end

        def self.base_migration_class
          ActiveRecord::Migration[unsafe_resource(:migration_version) || DEFAULT_MIGRATION_VERSION]
        end

        def build_class!
          @migration_class = Class.new(self.class.base_migration_class) do
            extend Kybus::DRY::ResourceInjector

            def self.precedense
              0
            end

            def change
              fields = self.class.resource(:fields)
              name = self.class.resource(:name)
              hooks = self.class.resource(:hooks)
              create_table(name, if_not_exists: true) do |t|
                fields.each { |f| t.column(f.name, f.type, **f.extra) }
                hooks.apply(:create_table, t)
              end
            end
          end

          @migrations << @migration_class
        end

        def inject_hooks!
          @migration_class.register(:fields, fields.values)
          @migration_class.register(:name, name)
          @migration_class.register(:hooks, @hooks)
        end

        def build_extra_migration!
          return unless @hooks.has?(:post_table)

          @extra_migation = Class.new(@migration_class) do
            def self.precedense
              1
            end

            def change
              hooks = self.class.superclass.resource(:hooks)
              hooks.apply(:post_table, self)
            end
          end

          @migrations << @extra_migation
        end

        def build!
          build_class!
          inject_hooks!
          build_extra_migration!
          @migrations
        end
      end
    end
  end
end
