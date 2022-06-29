# frozen_string_literal: true

require 'kybus/dry/resource_injector'
require_relative 'plugins/hook'
require_relative 'plugins/plugin_provider'

module Kybus
  module Nanorecord
    class ModelHooks
      def initialize(schema)
        @hooks = schema.models.keys.to_h { |table| [table, Plugins::Hook.new] }
        @schema = schema
      end

      def run!
        Plugins::PluginProvider.apply!(@schema, self)
      end

      def for_table(name)
        raise("#{name} does not exist") unless @hooks[name]

        @hooks[name]
      end

      def register_hook(table, type, &)
        for_table(table).register_hook(type, &)
      end
    end
  end
end
