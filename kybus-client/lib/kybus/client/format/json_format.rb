# frozen_string_literal: true

require 'json'

module Kybus
  module Client
    module Format
      # Implements JSON format for http clients.
      class JSONFormat
        def pack(data)
          {
            body: data.to_json,
            headers: { 'Content-type' => 'application/json; charset=UTF-8',
                       'User-Agent' => 'Ruby Kybus Client' }
          }
        end

        def unpack(data)
          unformat(data)
        end

        def unformat(msg)
          JSON.parse(msg, symbolize_names: true)
        end
      end
    end
  end
end
