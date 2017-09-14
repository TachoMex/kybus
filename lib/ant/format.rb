# frozen_string_literal: true

module Ant
  ##
  # See Exceptions module, since this is based on the exceptions too.
  # This will wrap a json object into a standard format, where the response
  # will contain some metadata about the status of the request
  module Format
    INTERNAL_SERVER_ERROR_CODE = 'INTERNAL_SERVER_ERROR'.freeze
    INTERNAL_SERVER_ERROR_MESSAGE = 'Unexpected error ocurred!'.freeze
    ##
    # success means there were no errors during the execution of the request
    # it sends the result in the data field.
    def success_status(data)
      { status: :success, data: data }
    end

    ##
    # an error on the request. It gives the details of the error.
    def fail_status(code, message, data)
      error_format(:fail, code, message, data)
    end

    ##
    # an error found while resolving the request.
    def error_status(code, message, data)
      error_format(:error, code, message, data)
    end

    ##
    # an unhandled error ocurred during the execution of the request.
    def fatal_status
      error_format(:fatal, INTERNAL_SERVER_ERROR_CODE,
                   INTERNAL_SERVER_ERROR_MESSAGE, {})
    end

    ##
    # helper to sumarize fatal and error status
    def error_format(level, code, message, data)
      { status: level, code: code, message: message, data: data }
    end
  end
end
