require 'kybus/dry/resource_injector'
require_relative './nanorecord/builder'
require_relative './nanorecord/migration_builder'

require_relative './nanorecord/model_hooks'

module Kybus
  module Nanorecord
    extend Kybus::DRY::ResourceInjector

    def self.load_schema!(models)
      hooks = ModelHooks.new(models)
      models = hooks.schema['models']
      migrations = build_model_migrations(models, hooks)
      migrations.each { |m| m.migrate(:up) }
      build_models(models, hooks)
    end

    def self.build_models(models, hooks)
      models.map do |model_name, fields|
        table_hooks = hooks.for_table(model_name)
        Builder.new(model_name, fields, table_hooks).build
      end
    end

    def self.build_model_migrations(models, hooks)
      models.map do |model_name, fields|
        table_hooks = hooks.for_table(model_name)
        MigrationBuilder.new(model_name, fields, table_hooks).build
      end.flatten.sort_by(&:precedense)
    end
  end
end