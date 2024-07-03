# frozen_string_literal: true

module Kybus
  class CLI < Thor
    class Bot < Thor
      class FileProvider
        def initialize(name, config)
          @file_writer = Kybus::CLI::FileWriter.new(name)
          @config = config
          @name = name
        end

        def skip_file?
          false
        end

        def keep_files
          []
        end

        def generate
          @file_writer.write(saving_path, make_contents) unless skip_file?
          keep_files.each do |file|
            @file_writer.write(file, '')
          end
        end

        def self.autoregister!
          Kybus::CLI::Bot::ProjectGenerator.register_file_provider(self)
        end

        def bot_name
          @name
        end

        def bot_name_class
          @name.split('_').map(&:capitalize).join
        end

        def bot_name_constantize
          bot_name_snake_case.upcase
        end

        def bot_name_snake_case
          @name.gsub(' ', '_').downcase
        end
      end
    end
  end
end
