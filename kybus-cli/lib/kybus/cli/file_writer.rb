module Kybus
  class CLI < Thor
    class FileWriter
      def initialize(base_path)
        @base_path = base_path
      end

      def write(relative_path, content)
        full_path = File.join(@base_path, relative_path)
        FileUtils.mkdir_p(File.dirname(full_path))
        File.write(full_path, content)
      end
    end
  end
end
