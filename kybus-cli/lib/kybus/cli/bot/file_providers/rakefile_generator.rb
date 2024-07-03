# frozen_string_literal: true

module Kybus
  class CLI < Thor
    class Bot < Thor
      module Config
        class RakefileGenerator < FileProvider
          autoregister!
          def saving_path
            './Rakefile'
          end

          private

          def make_contents
            <<~RAKEFILE
              require 'rake/testtask'
              task default: :test

              Rake::TestTask.new do |t|
                t.libs << 'test'
                t.warning = false
                t.pattern = 'test/**/test_*\.rb'
                t.warning = false
              end

              namespace :db do
                desc 'Run database migrations'
                task :migrate do
                  require_relative 'config_loaders/autoconfig'
                  run_migrations!
                end
              end
            RAKEFILE
          end
        end
      end
    end
  end
end
