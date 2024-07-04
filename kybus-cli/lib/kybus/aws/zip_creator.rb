# frozen_string_literal: true

require 'zip'
require 'fileutils'
module Kybus
  module AWS
    class ZipCreator
      def initialize(zip_name, directory, exclude_files: [], extra_files: {}, zip_root: '')
        @zip_name = zip_name
        @directory = directory
        @exclude_files = exclude_files
        @extra_files = extra_files
        @zip_root = zip_root
      end

      def create_zip
        FileUtils.rm(@zip_name, force: true)
        entries = fetch_entries

        Zip::File.open(@zip_name, Zip::File::CREATE) do |zipfile|
          add_extra_files(zipfile)
          add_entries(zipfile, entries)
        end
      end

      private

      def fetch_entries
        Dir.entries(@directory) - %w[. ..]
      end

      def add_extra_files(zipfile)
        @extra_files.each do |entry, contents|
          zipfile.get_output_stream(entry) { |f| f.puts(contents) }
        end
      end

      def add_entries(zipfile, entries)
        entries.each do |entry|
          entry_path = File.join(@directory, entry)
          next if should_exclude?(entry, entry_path)

          puts "Adding #{entry} to #{@zip_name}"

          if File.directory?(entry_path)
            add_directory(zipfile, entry_path)
          else
            add_file(zipfile, entry_path)
          end
        end
      end

      def should_exclude?(entry, entry_path)
        @exclude_files.any? { |pattern| File.fnmatch(pattern, entry) || File.fnmatch(pattern, entry_path) }
      end

      def add_directory(zipfile, entry_path)
        zipfile.mkdir("#{@zip_root}#{entry_path.sub(@directory, '')}")
        Dir[File.join(entry_path, '**', '**')].each do |file|
          next if should_exclude?(file, file)

          zipfile.add("#{@zip_root}#{file.sub(@directory, '')}", file)
        end
      end

      def add_file(zipfile, entry_path)
        zipfile.add("#{@zip_root}#{entry_path.sub(@directory, '')}", entry_path)
      end
    end
  end
end
