# frozen_string_literal: true

require 'yaml'

module Kybus
  module Configuration
    module Loaders
      # Class for loading yaml files
      class YAML
        def initialize(path)
          @path = path
        end

        # Parses and returns the file as a hash
        def load!
          ::YAML.load_file(@path)
        end
      end

      class FilesLoader
        include Utils
        attr_reader :files

        def initialize(files)
          @files = files
          seek_env_files
          @configs = {}
        end

        def seek_env_files
          return unless files.is_a?(String)

          @files = array_wrap(split_env_string(files)).compact
        end

        def load!
          files.each do |file|
            if File.file?(file)
              config = Loaders::YAML.new(file).load!
              @configs = recursive_merge(@configs, config)
            else
              # :nocov:
              puts "File not found and expected from autoconfig: `#{file}'"
              # :nocov:
            end
          end
          @configs
        end
      end
    end
  end
end
