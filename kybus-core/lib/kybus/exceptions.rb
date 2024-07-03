# frozen_string_literal: true

module Kybus
  module Exceptions
    autoload(:HTTP, 'kybus/http_exceptions.rb')
    ##
    # Exception used as standard error on this gem.
    # @param message.  This param is meant to be read by another developer
    #                  It would be nice if the message were self descriptive
    #                  enough so the developer won't need to ask the creator
    #                  of the app for help.
    # @param code.     The code is similar to message, but for this case
    #                  it is meant to be used for the program to handle
    #                  exceptions and to make easier to identify the exception..
    #                  The default is the exception class, so it won't change
    #                  almost never.
    # @param data.     Contains additional data to detail the error.
    class KybusBaseException < StandardError
      attr_reader :message, :code, :data

      def initialize(message, code, data)
        @message = message
        @code = code
        @data = data
        super(message)
      end

      def to_log_format
        to_h.merge(class: self.class.name)
      end

      def to_h
        {
          message:,
          code:,
          data:,
          backtrace:
        }
      end
    end

    ##
    # Is used to express a success with the client's request.
    class KybusSuccess < KybusBaseException
      def initialize(message, code = nil, data = {})
        code ||= self.class.name.split('::').last
        super
      end
    end

    ##
    # Is used to express a problem with the client's request.
    class KybusFail < KybusBaseException
      def initialize(message, code = nil, data = {})
        code ||= self.class.name.split('::').last
        code = 'BadRequest' if code == 'KybusFail'
        super
      end
    end

    ##
    # Is used to express an error that was found during the execution of the
    # program but it also means that the invoked endpoint has not the power to
    # fix it, so it will only complain.
    class KybusError < KybusBaseException
      def initialize(message, code = nil, data = {})
        code ||= self.class.name.split('::').last
        code = 'ServerError' if code == 'kybusError'
        super
      end
    end
  end
end
