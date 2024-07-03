# frozen_string_literal: true

require_relative 'crud_web_controller'

module Kybus
  module Nanorecord
    module Controller
      class WebControllers
        def initialize(configs, schema)
          @conf = configs
          @schema = schema
          @controllers = configs.to_h { |name, conf| [name, CRUDWebController.new(name, conf, schema.models[name])] }
        end

        def build!
          @controllers.each_value(&:build_class)
        end
      end
    end
  end
end
