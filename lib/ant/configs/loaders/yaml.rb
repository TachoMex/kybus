require 'yaml'
module Ant
  module Configuration
    module Loaders
      class YAML
        def initialize(path, manager)
          @path = path
          @manager = manager
        end

        def load!
          ::YAML.load_file(@path)
        end
      end
    end
  end
end
