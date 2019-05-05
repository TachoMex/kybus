# frozen_string_literal: true

# TODO: Comming soon!

require 'ant/core'

module Ant
  module Configuration
    # Allow to autoload configurations into ruby.
    # It allows to implement new plugins.
    class ServiceManager
      extend Ant::DRY::ResourceInjector
      def initialize(configs)
        @configs = configs
      end

      def register_plugin(name); end
    end
  end
end
