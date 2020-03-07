# frozen_string_literal: true

require 'json'
require_relative 'id_generators'

module Ant
  module Storage
    module Datasource
      # Wraps an object inside a model, this will allow to validate that
      # values are inside the restrictions. It dependes on a repository
      # for storing values.
      class Model
        attr_reader :data
        attr_writer :data

        # :nocov: #
        def run_validations!
          puts 'WARN: model with no validations'
        end
        # :nocov: #

        def []=(key, val)
          @data[key] = val
        end

        def [](key)
          @data[key]
        end

        def store
          run_validations!
          @repository.store(@data)
        end

        def create
          run_validations!
          @repository.create(@data)
        end

        def initialize(data)
          @data = data
        end

        attr_writer :repository

        def to_json(options = nil)
          @data.to_json(options)
        end
      end

      # This class is for explicit usage of models without validations
      class EmptyModel < Model
        def run_validations!; end

        def to_h
          @data
        end
      end
    end
  end
end
