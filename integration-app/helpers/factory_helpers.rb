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
        raise(Kybus::Exceptions::AntFail, 'nil value') unless data[:value]
      end
    end

    def json_repository
      @json_repository ||= JSONRepository.new('storage/tuples', :key, IDGenerators[:id])
    end

    def factory
      @factory ||= begin
        factory = Factory.new(Tuple)
        factory.register('json', json_repository)
        factory.register(:default, 'json')
        factory
      end
    end
  end
end
