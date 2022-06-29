# frozen_string_literal: true

module Kybus
  module Nanorecord
    module Plugins
      class Base
        def initialize(schema)
          @schema = schema
        end

        def tables
          models.keys
        end

        def table(name)
          models[name]
        end

        def append_field(table, name, conf)
          models['fields'][table][name] = conf
        end

        def config(table_name, config_name)
          table(table_name).configs.config_for(config_name)
        end

        def models
          @schema.models
        end
      end
    end
  end
end
