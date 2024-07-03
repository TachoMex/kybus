# frozen_string_literal: true

require_relative '../file_writer'
require_relative 'file_provider'
require 'kybus/dry/resource_injector'

module Kybus
  class CLI < Thor
    class Bot < Thor
      class ProjectGenerator
        extend Kybus::DRY::ResourceInjector
        register(:providers, [])

        def self.register_file_provider(file_provider)
          providers = resource(:providers)
          providers << file_provider
        end

        def initialize(name, configs)
          @name = name.gsub('::', '/')
                      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
                      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
                      .tr('-', '_')
                      .downcase
          @configs = configs
          @file_writer = FileWriter.new(@name)
        end

        def generate
          if File.directory?(@name)
            puts "Directory exists #{@name}"
            exit(1)
          end

          create_directories
          write_files
          puts `cd #{@name} && git init . && bundle install --path vendor/bundle && git add . && git commit -m "Initial Commit"`
          puts "Project #{@name} initialized with #{@configs[:db_adapter]} adapter."
        end

        private

        def create_directories
          %w[helpers models config_loaders config test].each do |dir|
            FileUtils.mkdir_p("#{@name}/#{dir}")
          end
        end

        def write_files
          @file_writer.write('main.rb', main_rb_content)
          @file_writer.write('helpers/.keep', '')
          @file_writer.write('.ruby-version', RUBY_VERSION)
          providers = ProjectGenerator.resource(:providers)
          providers.each do |provider|
            provider.new(@name, @configs).generate
          end
        end

        def main_rb_content
          <<~RUBY
            # frozen_string_literal: true

            require_relative 'config_loaders/autoconfig'
            require_relative 'config_loaders/bot_builder'

            if $PROGRAM_NAME == __FILE__
              BOT.run
            end
          RUBY
        end
      end
    end
  end
end

Dir[File.join(__dir__, 'file_providers', '*.rb')].each { |file| require file }
