# frozen_string_literal: true

module Kybus
  module Nanorecord
    module Plugins
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
          @hooks[type].each { |hook| hook.call(context) }
        end

        def has?(type)
          !@hooks[type].empty?
        end
      end
    end
  end
end
