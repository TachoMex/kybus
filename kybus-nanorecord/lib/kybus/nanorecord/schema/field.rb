# frozen_string_literal: true

module Kybus
  module Nanorecord
    class Schema
      class Field
        attr_reader :confs, :type, :name, :extra

        def initialize(name, confs)
          @confs = confs || {}
          @type = @confs['type']&.to_sym || :string
          @name = name.to_sym
          @extra = {
            null: @confs['not_null'],
            index: build_index
          }.compact
        end

        def build_index
          (@confs['unique'] || @confs['index']) && { unique: @confs['unique'] }
        end
      end
    end
  end
end
