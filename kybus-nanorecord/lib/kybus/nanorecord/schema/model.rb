# frozen_string_literal: true

require 'active_record'

require_relative 'model_migration'
require_relative 'field'
require_relative 'config'

module Kybus
  module Nanorecord
    class Schema
      class Model
        attr_reader :name, :configs, :fields

        def initialize(model_name, table_schema)
          @name = model_name.classify
          @fields = (table_schema['fields'] || {}).to_h { |name, confs| [name, Field.new(name, confs)] }
          @configs = Config.new(table_schema['configs'], self)
          @migration = ModelMigration.new(model_name, @fields, {})
        end

        def apply_plugins!(global_hooks)
          configs.plugins_config.each do |plugin|
            Plugins::PluginProvider.apply!(plugin, self, global_hooks)
          end
        end

        def build!
          klass = Class.new(ActiveRecord::Base)
          Object.const_set(name, klass)
          @hooks.apply(:model, klass)
          klass
        end

        def hooks=(hooks)
          @hooks = hooks
          @migration.hooks = hooks
        end

        def build_migration!
          @migration.build!
        end
      end
    end
  end
end
