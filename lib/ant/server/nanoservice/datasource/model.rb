# frozen_string_literal: true

require_relative 'id_generators'
require 'json'
module Ant
  module Server
    module Nanoservice
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
      end
    end
  end
end
