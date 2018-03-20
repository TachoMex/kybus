require 'json'

module Ant
  module Client
    module Format
      class JSONFormat
        def pack(data)
          {
            body: data.to_json,
            headers: { 'Content-type' => 'application/json; charset=UTF-8',
                       'User-Agent' => 'Ruby Ant Client' }
          }
        end

        def unpack(data)
          unformat(data.body)
        end

        def unformat(msg)
          JSON.parse(msg, symbolize_names: true)
        end
      end
    end
  end
end
