# frozen_string_literal: true

module Kybus
  module Client
    module Validator
      # Implements JSend specification on another backend calls
      class JSend
        include Kybus::Exceptions
        EXCEPTION_LIST = {
          'fail' => KybusFail,
          'error' => KybusError,
          'fatal' => KybusError
        }.freeze

        def validate(response)
          case response[:status]
          when 'success'
            response[:data]
          when 'fail', 'error', 'fatal'
            exception_klass = EXCEPTION_LIST[response[:status]]
            raise exception_klass.new(response[:message],
                                      response[:code],
                                      response[:data])
          else
            raise(KybusError, 'Unknown Error')
          end
        end
      end
    end
  end
end
