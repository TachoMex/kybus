# frozen_string_literal: true

module Kybus
  module Nanorecord
    class CRUDWebController
      def initialize(name, conf, model)
        @model = model
        @conf = conf
        @name = name
      end

      def build_class
        @klass = Class.new(base_controller_class) do
          extend Kybus::DRY::ResourceInjector

          def model
            self.class.resource(:kybus_model)
          end

          def index
            @objects = model.paginate(page: params[:page], per_page: 3)
          end

          def new
            @object = model.new
          end

          def edit; end
          def show; end

          def create
            @object = model.new(build_params)
            # user = current_user
            # @object.user = user
            if @object.save
              flash[:notice] = "#{model.name} added"
              redirect_to(@object)
            else
              render('new')
            end
          end

          def update
            if @object.update(build_params)
              flash[:notice] = 'Updated correctly'
              redirect_to(@object)
            else
              render('edit')
            end
          end

          def destroy
            @object.destroy
            redirect_to(request.referrer || send(:"#{model.name.tableize}_path"))
          end

          private

          def find_object
            @object = model.find(params[:id])
          end

          def build_params
            params.require(model.name.singularize.to_sym).permit(*expected_params_list, *expected_params_hash)
          end

          # def check_user
          #   require_user(@object.user, article_path(@object))
          # end
        end
      end

      def set_layout
        @klass.layout(conf['layout'])
      end

      def base_controller_class
        ActionController::Base
      end
    end
  end
end

# # frozen_string_literal: true

#   before_action :require_login, except: %i[index show]
#   before_action :check_user, only: %i[edit update destroy]

#   include ApplicationHelper
