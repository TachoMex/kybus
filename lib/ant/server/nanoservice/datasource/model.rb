require_relative 'id_generators'
module Ant
  module Server
    module Nanoservice
      module Datasource
        class Model
          attr_reader :data
          attr_writer :data

          def run_validations!
            puts 'WARN: model with no validations'
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

          def to_json(options)
            @data.to_json(options)
          end
        end
      end
    end
  end
end
