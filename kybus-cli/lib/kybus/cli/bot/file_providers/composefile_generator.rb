# frozen_string_literal: true

module Kybus
  class CLI < Thor
    class Bot < Thor
      class ComposefileGenerator < FileProvider
        autoregister!

        DB_SERVICES = {
          'dynamoid' => <<-LOCALSTACK.chomp,
  localstack:
    image: localstack/localstack
    ports:
      - "4566:4566"
    environment:
      - SERVICES=dynamodb
          LOCALSTACK
          'sequel' => <<-DATABASE.chomp
  db:
    image: postgres
    ports:
      - "5432:5432"
    environment:
      POSTGRES_DB: app_development
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
          DATABASE
        }.freeze

        def skip_file?
          !@config[:with_docker_compose]
        end

        def saving_path
          'docker-compose.yml'
        end

        def make_contents
          <<~DOCKERCOMPOSE + db_service_config
            version: '3'
            services:
              app:
                build: .
                volumes:
                  - .:/app
          DOCKERCOMPOSE
        end

        private

        def db_service_config
          DB_SERVICES[@config[:db_adapter]] || ''
        end
      end
    end
  end
end
