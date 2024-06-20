module Kybus
  class CLI < Thor
    class Bot < Thor
      module Config
        class TestHelperGenerator
          def initialize(name, with_simplecov)
            @file_writer = Kybus::CLI::FileWriter.new(name)
            @with_simplecov = with_simplecov
          end

          def generate
            @file_writer.write('test/test_helper.rb', test_helper_rb_content)
          end

          private

          def test_helper_rb_content
            content = <<-RUBY
# frozen_string_literal: true

require 'minitest/autorun'
            RUBY
            content << "\nrequire 'simplecov'\nSimpleCov.start" if @with_simplecov
            content
          end
        end
      end
    end
  end
end
