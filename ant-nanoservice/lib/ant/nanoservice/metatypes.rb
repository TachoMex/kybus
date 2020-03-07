# frozen_string_literal: true

require_relative 'validator'
require 'ant/storage'

module Ant
  module Nanoservice
    # This module is a factory of types. This will provide a class from the
    # configurations, attaching all the validations requested.
    # Currently it only plugs the validations and the repository inside the
    # factory so you can start using them on your code
    module MetaTypes
      extend Ant::DRY::ResourceInjector

      class << self
        include Ant::Storage::Exceptions
        def validation_builder(fields)
          fields.each_with_object({}) do |(field, plugins), obj|
            obj[field.to_sym] = plugins.map do |plug, conf|
              Validator.validator(plug).curry.call(conf)
            end
          end
        end

        def build_constructor(klass)
          klass.define_method :initialize do |data|
            @data = {}
            data.each do |key, val|
              case key
              when Symbol
                @data[key] = val if self.class::VALIDATIONS.key?(key)
              when String
                if self.class::VALIDATIONS.keys.map(&:to_s).include?(key)
                  @data[key.to_sym] = val
                end
              end
            end
          end
        end

        def build_validation_errors_method(klass)
          klass.define_method :validation_errors do
            result = {}
            self.class::VALIDATIONS.each do |key, validation|
              problems = validation.map { |val| val.call(@data[key]) }.compact
              result[key] = problems unless problems.empty?
            end
            result
          end
          klass.define_method :run_validations! do
            errors = validation_errors
            raise ValidationErrors, errors unless errors.empty?
          end
        end

        def primary_keys(fields)
          fields.select { |_, conf| conf['keys'] && conf['keys']['primary'] }
                .keys
                .first
                &.to_sym
        end

        def build(name, fields, _configs)
          validations = validation_builder(fields)
          klass = Class.new(Ant::Storage::Datasource::Model)
          build_constructor(klass)
          build_validation_errors_method(klass)
          class_name = name.split('_').collect(&:capitalize).join
          MetaTypes.const_set(class_name, klass)
          klass.const_set('VALIDATIONS', validations)
          klass.const_set('NAME', name)
          klass.const_set('PRIMARY_KEY', primary_keys(fields))
          klass
        end
      end
    end
  end
end
