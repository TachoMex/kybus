module Kybus
  class CLI < Thor
    class Bot < Thor
      class ComposefileGenerator < FileProvider
        autoregister!

        def skip_file?
          !@config[:with_docker_compose]
        end

        def saving_path
          'docker-compose.yml'
        end

        def make_contents
          content = <<~DOCKERCOMPOSE
            version: '3'
            services:
              app:
                build: .
                volumes:
                  - .:/app
          DOCKERCOMPOSE

          if @config[:db_adapter] == 'dynamoid'
            content << <<-LOCALSTACK
  localstack:
    image: localstack/localstack
    ports:
      - "4566:4566"
    environment:
      - SERVICES=dynamodb
            LOCALSTACK
          elsif @config[:db_adapter] == 'sequel'
            content << <<-DATABASE
  db:
    image: postgres
    ports:
      - "5432:5432"
    environment:
      POSTGRES_DB: app_development
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
            DATABASE
          end

          content
        end
      end
    end
  end
end
