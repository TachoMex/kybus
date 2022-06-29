# frozen_string_literal: true

module Kybus
  module Nanorecord
    module Plugins
      class PluginProvider
        extend Kybus::DRY::ResourceInjector

        def self.register_plugin(provider)
          plugins = unsafe_resource(:plugins) || []
          plugins << provider
          register(:plugins, plugins)
        end

        def self.apply!(schema, hooks)
          resource(:plugins).map do |provider|
            provider.new(schema).apply(hooks)
          end
        end
      end
    end
  end
end

require_relative 'relationships'
require_relative 'secure_password'
require_relative 'timestamps'
