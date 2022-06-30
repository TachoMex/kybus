# frozen_string_literal: true

module Kybus
  module Server
    # Descorator for using grape with kybus.
    # This will implement:
    # - exception handling
    # - logs
    # - JSend format
    module GrapeDecorator
      def self.handler
        lambda do |env, level, ex|
          params = env['api.endpoint'].params
          request = env['api.endpoint'].request
          pkg = RequestResponse.new(request:, params:)
          pkg.exception = ex
          Server::Response.logger.send(level, pkg)
          Server::Response.format.send(level, pkg)
        end
      end

      HTTP_CODES = {
        success: 200, fail: 400, error: 500, fatal: 500
      }.freeze

      def self.extract_http_code(exception, level)
        default = HTTP_CODES[level] || 500
        exception.respond_to?(:http_code) ? exception.http_code : default
      end

      def self.configure_custom_exceptions(base)
        Server::Response.resources(:exceptions).each do |exception_class, level|
          base.rescue_from(exception_class) do |ex|
            response = Kybus::Server::GrapeDecorator.handler.call(env, level, ex)
            http_code = Kybus::Server::GrapeDecorator.extract_http_code(ex, level)
            error!(response, http_code)
          end
        end
      end

      # :nocov: #
      def self.configure_grape_exceptions(base)
        base.rescue_from(Grape::Exceptions::Base) do |ex|
          ant_ex = Kybus::Exceptions::AntFail.new(ex.message)
          response = Kybus::Server::GrapeDecorator
                     .handler.call(env, :fail, ant_ex)
          error!(response, 400)
        end
      end
      # :nocov: #

      def self.configure_global_exception_handler(base)
        base.rescue_from(:all) do |ex|
          level = :fatal
          response = Kybus::Server::GrapeDecorator.handler.call(env, level, ex)
          http_code = Kybus::Server::GrapeDecorator.extract_http_code(ex, level)
          error!(response, http_code)
        end
      end

      def self.configure_handlers(base)
        configure_custom_exceptions(base)
        configure_grape_exceptions(base)
        configure_global_exception_handler(base)
      end

      def self.included(base)
        base.formatter(:json, lambda do |response, _|
          pkg = RequestResponse.new(request: {}, params: {})
          pkg.result = response
          Server::Response.format.send(:success, pkg).to_json
        end)
        configure_logger(base)
        configure_handlers(base)
      end

      def self.configure_logger(base)
        base.before do
          params[:__init_time] = Time.now
        end
        base.after do
          params = env['api.endpoint'].params
          request = env['api.endpoint'].request
          pkg = RequestResponse.new(request:, params:)
          Server::Response.logger.access(pkg)
        end
      end
    end
  end
end
