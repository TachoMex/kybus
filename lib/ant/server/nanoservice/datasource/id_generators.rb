module Ant
  module Server
    module Nanoservice
      module Datasource
        class IDGenerators
          extend DRY::ResourceInjector
          def self.[](key)
            resource(:generators, key)
          end

          def self.normalize_id(object, key)
            object.is_a?(Hash) ? object[key] : object
          end

          id_generator = lambda { |id, key| normalize_id(id, key) }
          register(:generators, :id, id_generator)
        end
      end
    end
  end
end
