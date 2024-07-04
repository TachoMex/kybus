# frozen_string_literal: true

require 'digest'
require_relative 'zip_creator'

module Kybus
  module AWS
    class CodePackager < Resource
      def create_or_update!
        ruby_version = fetch_ruby_version
        create_deps_zip(ruby_version)
        create_code_zip(ruby_version)
      end

      def destroy!; end

      private

      def fetch_ruby_version
        "#{RUBY_VERSION.split('.')[0..1].join('.')}.0"
      end

      def create_deps_zip(ruby_version)
        ZipCreator.new(
          '.deps.zip',
          "vendor/bundle/ruby/#{ruby_version}",
          zip_root: "ruby/gems/#{ruby_version}"
        ).create_zip
      end

      def create_code_zip(_ruby_version)
        ZipCreator.new(
          '.kybuscode.zip',
          @config['repo_path'],
          exclude_files: excluded_files,
          extra_files: { '.bundle/config' => 'BUNDLE_PATH: "/opt/vendor/bundle"' },
          zip_root: '.'
        ).create_zip
      end

      def excluded_files
        [
          'test', 'Gemfile*', 'Rakefile', '.gitignore', '.bundle', '.git', '.deps.zip',
          '.kybuscode.zip', 'kybusbot.yaml', 'vendor', '.ruby-version'
        ]
      end
    end
  end
end
