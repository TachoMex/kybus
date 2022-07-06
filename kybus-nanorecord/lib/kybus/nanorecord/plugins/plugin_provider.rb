# frozen_string_literal: true

module Kybus
  module Nanorecord
    module Plugins
      class PluginProvider
        extend Kybus::DRY::ResourceInjector

        def self.register_plugin(name, provider)
          register(:plugins, name, provider)
        end

        def self.apply!(config, model, hooks)
          provider = resource(:plugins, config['name'])
          provider.new(model).apply!(config, hooks)
        end
      end
    end
  end
end

require_relative 'relationships'
require_relative 'secure_password'
require_relative 'timestamps'
