# frozen_string_literal: true

require_relative 'validator'

module Ant
  module Server
    module Nanoservice
      module MetaTypes
        extend Ant::DRY::ResourceInjector

        def self.build(name, fields)
          validations = fields.each_with_object({}) do |(field, plugins), obj|
            obj[field.to_sym] = plugins.map { |plug, conf| Validator.validator(plug).curry.call(conf) }
          end
          klass = Class.new(Ant::Server::Nanoservice::Datasource::Model) do

            def validation_errors
              result = {}
              self.class::VALIDATIONS.each do |key, validation|
                problems = validation.map { |val| val.call(@data[key]) }.compact
                result[key] = problems unless problems.empty?
              end
              result
            end

            def run_validations!
              errors = validation_errors
              raise Ant::Exceptions::AntFail.new('Errors found on validation', 'INVALID_DATA', errors) unless errors.empty?
            end
          end

          MetaTypes.const_set(name.split('_').collect(&:capitalize).join, klass)
          klass.const_set('VALIDATIONS', validations)
          klass
        end
      end
    end
  end
end
