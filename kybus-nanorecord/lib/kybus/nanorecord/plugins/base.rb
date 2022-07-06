# frozen_string_literal: true

module Kybus
  module Nanorecord
    module Plugins
      class Base
        attr_reader :model

        def initialize(model)
          @model = model
        end

        def table
          model.name.tableize
        end
      end
    end
  end
end
