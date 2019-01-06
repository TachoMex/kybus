require 'yaml'

module Ant
  module Configuration
    module Loaders
      # Class for loading yaml files
      class YAML
        def initialize(path, manager)
          @path = path
          @manager = manager
        end

        # Parses and returns the file as a hash
        def load!
          ::YAML.load_file(@path)
        end
      end
    end
  end
end
