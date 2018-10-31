# frozen_string_literal: true

require './lib/ant/exceptions'

module Exceptions
  module HTTP
    class << self
      EXCEPTION_TYPES = {
        success: Ant::Exceptions::AntSuccess,
        fail: Ant::Exceptions::AntFail,
        error: Ant::Exceptions::AntError
      }.freeze

      def new_http_exception(class_name, http_code, type)
        parent = exception_type(type)
        http_exception_class = Class.new(parent) do
          def initialize(message, object = {})
            super(message, nil, object)
          end

          define_method 'http_code' do
            http_code
          end
        end

        const_set(class_name, http_exception_class)
      end

      private

      def exception_type(type)
        EXCEPTION_TYPES[type.to_sym]
      end
    end

    http_codes = [
      { code_name: 'Ok', code: 200, type: :success },
      { code_name: 'Created', code: 201, type: :success },
      { code_name: 'Accepted', code: 202, type: :success },
      { code_name: 'NoContent', code: 203, type: :success },
      { code_name: 'BadRequest', code: 400, type: :fail },
      { code_name: 'Unauthorized', code: 401, type: :fail },
      { code_name: 'Forbidden', code: 403, type: :fail },
      { code_name: 'NotFound', code: 404, type: :fail },
      { code_name: 'NotValid', code: 422, type: :fail }
    ]

    http_codes.each do |code|
      Exceptions::HTTP.new_http_exception(
        code[:code_name],
        code[:code],
        code[:type]
      )
    end
  end
end
