require 'active_record'

module Kybus
  module Nanorecord
    class Builder
      attr_reader :name
      def initialize(name, schema, hooks)
        @name = name.classify
        @schema = schema
        @hooks = hooks
      end

      def build
        klass = Class.new(ActiveRecord::Base)
        Object.const_set(name, klass)
        @hooks.apply(:model, klass)
        klass
      end
    end
  end
end