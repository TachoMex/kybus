# frozen_string_literal: true

require_relative 'json_format'
require_relative 'url_encoded'

module Kybus
  module Client
    # Singleton storing all the formats implemented for http clients.
    module Format
      extend Kybus::DRY::ResourceInjector
      class << self
        def build(config)
          resource(:formats, config[:format] || 'json').new
        end

        def register_format(name, klass)
          register(:formats, name, klass)
        end
      end
      register_format('json', JSONFormat)
      register_format('url_encoded', URLEncodedFormat)
    end
  end
end
