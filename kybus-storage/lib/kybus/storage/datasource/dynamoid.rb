# frozen_string_literal: true

module Kybus
  module Storage
    module Datasource
      # Repository that fetches and stores objects using a Dynamoid connection
      class DynamoidRepository < Repository
        attr_reader :model_class

        def self.configure_dynamoid
          require 'dynamoid'
          keys = %w[access_key secret_key region namespace endpoint]
          Dynamoid.configure do |config|
            keys.each do |key|
              config.send("#{key}=", conf[key])
            end
          end
        end

        def self.from_config(conf)
          configure_dynamoid(conf['dynamoid_config']) if conf['dynamoid_config']

          model_class = conf['schema'] || create_dynamic_model(conf)
          new(model_class, conf['primary_key'].to_sym)
        end

        def table_config(conf)
          { name: conf['table'],
            key: conf['primary_key'].to_sym,
            read_capacity: conf['read_capacity'],
            write_capacity: conf['write_capacity'] }
        end

        def self.create_dynamic_model(conf)
          Class.new do
            include Dynamoid::Document

            table(table_config(conf))

            # Dynamically add fields based on configuration
            conf['fields'].each do |field, type|
              field field.to_sym, type.to_sym
            end

            # Set a constant name for the dynamic class
            class_eval { const_set("DynamicModel#{conf['table'].upcase}", self) }
          end
        end

        def initialize(model_class, id)
          @model_class = model_class
          super(id, IDGenerators[:id])
        end

        def get(id)
          result = @model_class.find(id)
          raise(ObjectNotFound, id) if result.nil?

          result.attributes
        rescue Dynamoid::Errors::RecordNotFound
          raise(ObjectNotFound, id)
        end

        def create_(data)
          obj = @model_class.create(data)
          obj.attributes
        end

        def store(data)
          obj = @model_class.find(data[@id])
          raise(ObjectNotFound, data[@id]) if obj.nil?

          obj.update_attributes(data)
          obj.attributes
        end

        def connection
          @model_class.connection
        end
      end
      Kybus::Storage::Repository.register(:repositories, :dynamoid, DynamoidRepository)
      Kybus::Storage::Repository.register(:repositories, 'dynamoid', DynamoidRepository)
    end
  end
end
