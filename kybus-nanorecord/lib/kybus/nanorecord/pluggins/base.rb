module Kybus
  module Nanorecord
    module Pluggins
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
          conf = table(table_name)['configs']
          case conf
          when Array
            return {} if conf.include?(config_name)

            conf.find { |hash| hash.is_a?(Hash) && (hash['name'] == config_name || hash[config_name]) }
          when Hash
            conf[config_name]
          when String
            conf == config_name && {}
          end
        end

        def models
          @schema['models']
        end
      end
    end
  end
end
