# frozen_string_literal: true

module Kybus
  module Configuration
    class FeatureFlag
      class Base
        def initialize(configs)
          @enabled = configs
        end

        def active?
          @enabled
        end
      end
    end
  end
end
