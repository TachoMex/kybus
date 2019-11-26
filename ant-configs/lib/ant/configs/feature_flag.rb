# frozen_string_literal: true

require_relative 'feature_flag/feature_flag'
require_relative 'feature_flag/ab_test'
require_relative 'feature_flag/canarying'

module Ant
  module Configuration
    class FeatureFlag
      extend Ant::DRY::ResourceInjector

      def initialize(confs)
        @flags = {}
        confs.each do |name, conf|
          @flags[name] = self.class.from_config(conf)
        end
      end

      def [](key)
        feature_flag = @flags[key]
        raise KeyError, "#{key} is not configured as flag" unless feature_flag

        feature_flag.active?
      end

      def self.from_config(conf)
        case conf
        when String, TrueClass, FalseClass
          Base.new(conf)
        when Hash
          klass = resource(:custom_provider, conf['provider'])
          klass.new(conf)
        end
      end

      def self.register_provider(name, klass)
        register(:custom_provider, name, klass)
      end

      register_provider('canarying', Canarying)
      register_provider('ab_test', ABTest)
    end
  end
end
