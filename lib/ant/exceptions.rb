module Ant
  module Exceptions
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
    class AntBaseException < StandardError
      attr_reader :message, :code, :data
      def initialize(message, code, data)
        @message = message
        @code = code
        @data = data
      end
    end

    ##
    # Is used to express a success with the client's request.
    class AntSuccess < AntBaseException
      def initialize(message, code = nil, data = {})
        code ||= self.class.name.split('::').last
        super(message, code, data)
      end
    end

    ##
    # Is used to express a problem with the client's request.
    class AntFail < AntBaseException
      def initialize(message, code = nil, data = {})
        code ||= self.class.name.split('::').last
        code = 'BadRequest' if code == 'AntFail'
        super(message, code, data)
      end
    end

    ##
    # Is used to express an error that was found during the execution of the
    # program but it also means that the invoked endpoint has not the power to
    # fix it, so it will only complain.
    class AntError < AntBaseException
      def initialize(message, code = nil, data = {})
        code ||= self.class.name.split('::').last
        code = 'ServerError' if code == 'AntError'
        super(message, code, data)
      end
    end
  end
end
