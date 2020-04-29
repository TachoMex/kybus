# frozen_string_literal: true

module Kybus
  module Configuration
    class FeatureFlag
      class ABTest
        def initialize(configs)
          @configs = configs
          @threshold = normalize_thershold(configs['threshold'])
        end

        def normalize_thershold(value)
          case value
          when Integer
            raise 'Value out of range' unless (0..100).cover?(value)

            value.to_f / 100
          when Float
            raise 'Value out of range' unless (0..1).cover?(value)

            value
          end
        end

        def active?
          rand <= @threshold
        end
      end
    end
  end
end
