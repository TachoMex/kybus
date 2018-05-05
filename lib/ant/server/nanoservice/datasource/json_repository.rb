require_relative 'repository'

module Ant
  module Server
    module Nanoservice
      module Datasource
        class JSONRepository < Repository
          def initialize(folder, id, id_generator)
            @path = folder
            super(id, id_generator)
          end

          def get(id)
            path = full_path(id)
            raise(ObjectNotFound, id) unless File.file?(path)
            contents = File.read(path)
            JSON.parse(contents, symbolize_names: true)
          end

          def create_(data)
            store(data)
            data
          end

          def store(data)
            id = data[@id]
            File.write(full_path(id), data.to_json)
          end

          private

          def full_path(id)
            "#{@path}/#{id}.json"
          end
        end
      end
    end
  end
end
