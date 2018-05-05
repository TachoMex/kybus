class DevelopmentAPI < Grape::API
  module FactoryHelpers
    include Ant::Server::Nanoservice
    include Datasource
    include Exceptions

    class Tuple < Model
      def run_validations!
        raise(Ant::Exceptions::AntFail, 'nil value') if @data[:value].nil?
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
        factory.register(:default, :sequel)
        factory
      end
    end
  end
end
