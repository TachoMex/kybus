# frozen_string_literal: true

require_relative 'ux/base'
require_relative 'ux/telegram'

module Kybus
  module Bot
    # Enhanced UX renderers for providers (pagination, edit, buttons).
    module UX
      extend Kybus::DRY::ResourceInjector
      register(:default, Base)
      register(:telegram, Telegram)

      def self.for(provider)
        key = provider.class.name.split('::').last.downcase.to_sym
        renderer = unsafe_resource(key) || resource(:default)
        renderer.new(provider)
      end
    end
  end
end
