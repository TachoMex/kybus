# frozen_string_literal: true

require_relative 'json_format'

module Ant
  module Client
    module Format
      # Allows to send data url encoded as a regular http client.
      class URLEncodedFormat < JSONFormat
        def pack(data)
          {
            body: encode(data),
            headers: { 'Content-type' =>
                       'application/x-www-form-urlencoded; charset=UTF-8' }
          }
        end

        def encode(data)
          data.map { |k, v| "#{k}=#{v}" }.join('&')
        end
      end
    end
  end
end
