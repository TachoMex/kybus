# frozen_string_literal: true

class DevelopmentAPI < Grape::API
  # implements an obsolete way of helpers. See Schema#mount_grape_helpers.
  # Provides some helpers that will allow the tuple api to access a factory.
  # This tuple API would help to develop the repositories components.
  module FactoryHelpers
    include Kybus::Nanoservice
    include Kybus::Storage::Datasource
    include Kybus::Storage
    include Kybus::Storage::Exceptions

    # Models a single tuple as a key => value object.
    class Tuple < Model
      def run_validations!
        raise(Kybus::Exceptions::AntFail, 'nil value') if @data[:value].nil?
      end
    end

    def json_repository
      @json_repository ||= JSONRepository.new(
        'storage/tuples',
        :key,
        IDGenerators[:id]
      )
    end

    def sequel_repository
      @sequel_repository ||= begin
        db = ::Sequel.sqlite('storage/tuples.db')
        db.create_table? :tuple do
          column :key, :text, size: 40, primary_key: true
          column :value, :text, size: 40
        end
        Sequel.new(
          db[:tuple],
          :key,
          IDGenerators[:id]
        )
      end
    end

    def factory
      @factory ||= begin
        factory = Factory.new(Tuple)
        factory.register(:json, json_repository)
        factory.register('json', json_repository)
        factory.register(:sequel, sequel_repository)
        factory.register('sequel', sequel_repository)
        factory.register(:default, :json)
        factory
      end
    end
  end
end
