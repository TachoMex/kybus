require_relative 'json_format'
require_relative 'url_encoded'

module Ant
  module Client
    module Format
      class << self
        def build(config)
          @formats ||= default_formats
          @formats[config[:format]].new
        end

        def default_formats
          {
            json: JSONFormat,
            url_encoded: URLEncodedFormat
          }
        end
      end
    end
  end
end
