# frozen_string_literal: true

module Kybus
  module AWS
    class CodePackager < Resource
      def create_or_update!
        require 'zip'
        FileUtils.rm(@config['output_path'], force: true)
        entries = Dir.entries(@config['repo_path']) - %w[. ..]

        zipfile_name = @config['output_path']

        Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
          entries.each do |entry|
            entry_path = File.join(@config['repo_path'], entry)
            if File.directory?(entry_path)
              zipfile.mkdir(entry)
              Dir[File.join(entry_path, '**', '**')].each do |file|
                zipfile.add(file.sub("#{@config['repo_path']}/", ''), file)
              end
            else
              zipfile.add(entry, entry_path)
            end
          end
        end
      end

      def destroy!; end
    end
  end
end
