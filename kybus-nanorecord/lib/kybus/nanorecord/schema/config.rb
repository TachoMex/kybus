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

        def pase_array(config_name)
          return {} if raw.include?(config_name)

          raw.find { |hash| hash.is_a?(Hash) && (hash['name'] == config_name || hash[config_name]) }
        end

        def config_for(config_name)
          case raw
          when Array
            pase_array(config_name)
          when Hash
            raw[config_name]
          when String
            raw == config_name ? {} : nil
          end
        end
      end
    end
  end
end
