require 'kybus/dry/resource_injector'
module Kybus
  module Nanorecord
    class ModelHooks
      extend Kybus::DRY::ResourceInjector

      class Hook
        def initialize
          @hooks = {
            create_table: [],
            post_table: [],
            model: []
          }
        end

        def register_hook(type, &block)
          @hooks[type] << block
        end

        def apply(type, context)
          @hooks[type].each{ |hook| hook.call(context) }
        end

        def has?(type)
          !@hooks[type].empty?
        end
      end

      def self.register_plugin(provider)
        plugins = unsafe_resource(:plugins) || []
        plugins << provider
        register(:plugins, plugins)
      end

      def initialize(schema)
        @schema = schema.clone
        @hooks = schema['models'].keys.map { |table| [table, Hook.new] }.to_h

        @pluggins = self.class.resource(:plugins).map do |provider|
          provider.new(@schema).apply(self)
        end
      end

      def for_table(name)
        raise ("#{name} does not exist") unless @hooks[name]
        @hooks[name]
      end

      def register_hook(table, type, &)
        for_table(table).register_hook(type, &)
      end

      def schema
        @schema
      end
    end
  end
end

require_relative 'pluggins/relationships'
require_relative 'pluggins/secure_password'
require_relative 'pluggins/timestamps'
