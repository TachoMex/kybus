# frozen_string_literal: true

module Kybus
  module Nanorecord
    class Schema
      class Config
        attr_reader :raw

        def initialize(confs, model)
          @raw = confs
          @model = model
        end

        def parse_array
          raw.map { |str| str.is_a?(String) ? parse_string(str) : str }
        end

        def parse_string(str = raw)
          { 'name' => str }
        end

        def config_for(config_name)
          plugins_config.select { |h| h['name'] == config_name }.first
        end

        def plugins_config
          case raw
          when Array
            parse_array
          when String
            parse_string
          else
            []
          end
        end
      end
    end
  end
end
