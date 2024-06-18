module Kybus
  module Storage
    module Datasource
      # Repository that fetches and stores objects using a Dynamoid connection
      class DynamoidRepository < Repository
        attr_reader :model_class

        def self.from_config(conf)
          if conf['dynamoid_config']
            require 'dynamoid'
            Dynamoid.configure do |config|
              config.access_key = conf['access_key']
              config.secret_key = conf['secret_key']
              config.region = conf['region']
              config.namespace = conf['namespace']
              config.endpoint = conf['endpoint'] if conf['endpoint']
            end
          end

          model_class = conf['schema'] || create_dynamic_model(conf)
          new(model_class, conf['primary_key'].to_sym)
        end

        def self.create_dynamic_model(conf)
          Class.new do
            include Dynamoid::Document

            table name: conf['table'], key: conf['primary_key'].to_sym

            # Dynamically add fields based on configuration
            conf['fields'].each do |field, type|
              field field.to_sym, type.to_sym
            end

            # Set a constant name for the dynamic class
            self.class_eval { const_set("DynamicModel#{conf['table'].upcase}", self) }
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