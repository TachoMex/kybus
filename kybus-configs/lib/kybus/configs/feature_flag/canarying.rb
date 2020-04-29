# frozen_string_literal: true

module Kybus
  module Configuration
    class FeatureFlag
      class Canarying < ABTest
        def initialize(configs)
          @enabled = configs
          @initial_time = initial_time(configs['starting_hour'])
          @threshold = normalize_thershold(configs['initial'] || 0)
          @step = normalize_thershold(configs['step'])
          @step_duration = configs['step_duration']
        end

        def active?
          rand <= threshold_calculation
        end

        def threshold_calculation
          @threshold + (Time.now - @initial_time).to_i / @step_duration.to_i * @step
        end

        def initial_time(time)
          return Time.now if time.nil?

          Time.parse(time)
        end
      end
    end
  end
end
