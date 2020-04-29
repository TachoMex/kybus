# frozen_string_literal: true

require_relative 'repository'
require_relative 'id_generators'
require_relative 'model'
require 'fileutils'

module Kybus
  module Storage
    module Datasource
      # Stores objects as a plain json file inside the specified folder.
      # Uses this for testing purpouse.
      class JSONRepository < Repository
        def self.from_config(conf)
          folder = conf['storage']
          folder.gsub!('$name', conf['schema_name']) if conf['schema_name']
          if conf['schema'].nil?
            # TODO: decouple use of classes
            new(folder, conf['primary_key'].to_sym,
                IDGenerators[:id])
          else
            # TODO: This line is very high coupled to kybus-nanoservice
            new(folder, conf['schema']::PRIMARY_KEY, IDGenerators[:id])
          end
        end

        def initialize(folder, id, id_generator)
          @path = folder
          FileUtils.mkdir_p folder
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
