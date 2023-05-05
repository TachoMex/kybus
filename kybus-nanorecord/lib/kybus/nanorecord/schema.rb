# frozen_string_literal: true

require_relative 'model_hooks'
require_relative 'schema/model'
require_relative 'controller/web_controllers'

module Kybus
  module Nanorecord
    class Schema
      attr_reader :models

      def initialize(conf)
        @models = conf['schema']['models'].to_h { |name, fields| [name, Model.new(name, fields)] }
        @hooks = ModelHooks.new(self)
        @models.each { |name, model| model.hooks = @hooks.for_table(name) }
        apply_plugins!
        @controllers = Controller::WebControllers.new(conf.dig('schema', 'controllers', 'web'), self)
      end

      def apply_plugins!
        @models.each_value { |model| model.apply_plugins!(@hooks) }
      end

      def self.load_file!(path)
        conf = YAML.load_file(path)
        new(conf)
      end

      def build_models
        @models.map { |_, model| model.build! }
      end

      def build_controllers!
        @controllers.build!
      end

      def build_model_migrations
        @models.map { |_, model| model.build_migration! }.flatten.sort_by(&:precedense)
      end

      def run_migrations!
        @migrations = build_model_migrations
        @migrations.each { |m| m.migrate(:up) }
      end

      def build_classes!
        build_models
      end
    end
  end
end
