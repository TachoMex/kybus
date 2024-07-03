# frozen_string_literal: true

module Kybus
  class CLI < Thor
    class Bot < Thor
      class DockerfileGenerator
        def initialize(name)
          @name = name
          @file_writer = Kybus::CLI::FileWriter.new(name)
        end

        def generate
          @file_writer.write('Dockerfile', dockerfile_content)
        end

        private

        def dockerfile_content
          <<~DOCKERFILE
            FROM ruby:#{RUBY_VERSION}

            WORKDIR /app
            COPY . /app

            RUN bundle install

            CMD ["ruby", "main.rb"]
          DOCKERFILE
        end
      end
    end
  end
end
