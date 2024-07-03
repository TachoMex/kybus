# frozen_string_literal: true

module Kybus
  module AWS
    class CodePackager < Resource
      def create_or_update!
        ruby_version = "#{RUBY_VERSION.split('.')[0..1].join('.')}.0"
        create_zip('.deps.zip', "vendor/bundle/ruby/#{ruby_version}", zip_root: "ruby/gems/#{ruby_version}")
        create_zip('.kybuscode.zip', @config['repo_path'], exclude_files: [
                     'test', 'Gemfile*', 'Rakefile', '.gitignore', '.bundle', '.git', '.deps.zip', '.kybuscode.zip', 'kybusbot.yaml', 'vendor', '.ruby-version'
                   ], extra_files: { '.bundle/config' => 'BUNDLE_PATH: "/opt/vendor/bundle"' }, zip_root: '.')
      end

      def create_zip(zip_name, directory, exclude_files: [], extra_files: {}, zip_root: '')
        require 'zip'
        FileUtils.rm(zip_name, force: true)
        entries = Dir.entries(directory) - %w[. ..]

        Zip::File.open(zip_name, Zip::File::CREATE) do |zipfile|
          extra_files.each do |entry, contents|
            zipfile.get_output_stream(entry) { |f| f.puts(contents) }
          end

          entries.each do |entry|
            entry_path = File.join(directory, entry)
            next if exclude_files.any? { |pattern| File.fnmatch(pattern, entry) || File.fnmatch(pattern, entry_path) }

            puts "Adding #{entry} to #{zip_name}"

            if File.directory?(entry_path)
              zipfile.mkdir("#{zip_root}#{entry_path.sub(directory, '')}")
              Dir[File.join(entry_path, '**', '**')].each do |file|
                next if exclude_files.any? { |pattern| File.fnmatch(pattern, file) }

                zipfile.add("#{zip_root}#{file.sub(directory, '')}", file)
              end
            else
              zipfile.add("#{zip_root}#{entry_path.sub(directory, '')}", entry_path)
            end
          end
        end
      end

      def destroy!; end
    end
  end
end
