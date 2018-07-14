require_relative '../exceptions'
require_relative '../dry/resource_injector'
require_relative 'format'
require_relative 'logger'
require_relative 'request_response'

module Ant
  module Server
    ##
    # This module provides a function to wrap lambdas arround grape/sinatra
    # You can mount this module as helper in your application and wrap the block
    # with the method `process_request`
    module Response
      include Exceptions
      extend DRY::ResourceInjector

      class << self
        attr_reader :logger, :format

        def log_mode(mode)
          @logger = resource(:loggers, mode)
        end

        def format_mode(mode)
          @format = resource(:formats, mode)
        end

        def recover_from!(exception_class, level)
          register(:exceptions, exception_class, level)
        end

        def configure_defaults!
          recover_from!(Exceptions::AntSuccess, :success)
          recover_from!(Exceptions::AntFail, :fail)
          recover_from!(Exceptions::AntError, :error)
          register(:loggers, :cute_logger, Server::CuteLogger.new)
          register(:formats, :jsend, Server::Format.new)
          log_mode(:cute_logger)
          format_mode(:jsend)
        end
      end

      def exception_handler(exception)
        Server::Response.resources(:exceptions).each do |klass, recover|
          return recover if exception.is_a?(klass)
        end
        exception.is_a?(StandardError) ? :fatal : nil
      end

      def handle(resolver, data)
        if resolver
          Server::Response.logger.send(resolver, data)
          Server::Response.format.send(resolver, data)
        else
          Server::Response.logger.fatal(data)
          raise(data.exception)
        end
      end

      def process_request
        data = RequestResponse.new(request: request, params: params)
        resolver = :success
        Server::Response.logger.access(data)
        begin
          raise(AntError, 'No implementation given') unless block_given?
          data.result = yield
          # rubocop: disable RescueException
        rescue Exception => ex
          # rubocop: enable RescueException
          data.exception = ex
          resolver = exception_handler(ex)
        end
        handle(resolver, data)
      end
    end
  end
end

# Allow backwards compatibility
Ant::Server::Response.configure_defaults!
