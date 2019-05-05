# frozen_string_literal: true

require 'ant/storage'

module Ant
  module Nanoservice
    # This module is a singleton that stores all the validator plugins
    # A validator plugin is introduced into metatypes and used to validate
    # that types are properly validated.
    # See more on the validators documentations.
    module Validator
      extend Ant::DRY::ResourceInjector
      def self.register_plugin(name)
        block = lambda do |value, conf|
          yield(value, conf) ? nil : "#{name} failed!"
        end
        register(:validators, name, block)
      end

      def self.validator_alias(name, new_name)
        validator = resource(:validators, name)
        register(:validators, new_name, validator)
      end

      def self.register_type(type)
        block = proc { |value| yield(value) }
        register(:types, type, block)
      end

      def self.type_alias(type, new_name)
        validator = resource(:types, type)
        register(:types, new_name, validator)
      end

      def self.validator(name)
        resource(:validators, name)
      end

      register_plugin('keys') do |_conf, _val|
        true
      end

      register_plugin('range') do |conf, val|
        val.nil? || (conf['min']..conf['max']).cover?(val)
      end

      register_plugin('not_nil') do |_conf, val|
        !val.nil?
      end

      validator_alias('not_nil', 'not_null')

      register_plugin('size') do |size, val|
        val.nil? || val.size <= size
      end

      validator_alias('size', 'length')

      register_plugin('pattern') do |regex, val|
        val.nil? || Regexp.new(regex).match?(val)
      end
      validator_alias('pattern', 'regex')

      register_plugin('type') do |type, val|
        type_validator = resource(:types, type)
        val.nil? || type_validator.call(val)
      end

      register_type('numeric') { |val| val.is_a?(Numeric) }
      register_type('text') { |val| val.is_a?(String) }
      register_type('int') { |val| val.is_a?(Integer) }
      register_type('date') { |val| val.is_a?(Date) }
      register_type('timestamp') { |val| val.is_a?(DateTime) }

      type_alias('text', 'string')
    end
  end
end
