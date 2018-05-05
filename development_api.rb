require './lib/ant'
require './lib/ant/nanoservice'
require 'grape'
require './lib/ant/server/grape'
require 'sequel'

class DevelopmentAPI < Grape::API
  include Ant::Server::GrapeDecorator

  version('v1', using: :header, vendor: :cut)
  prefix(:api)
  format(:json)

  get :status do
    log_info('Requesting status for server')
    {
      status: 'server running',
      time: Time.now,
      hello: 'world'
    }
  end

  get :fatal do
    log_info('trying to do magic')
    raise('I do not know what happened')
  end

  get :fail do
    raise(Ant::Exceptions::AntFail, 'Wrong Value')
  end

  get :error do
    raise(Ant::Exceptions::AntError, 'The system crashed')
  end

  module FactoryHelpers
    include Ant::Server::Nanoservice
    include Datasource
    include Exceptions

    class Tuple < Model
      def run_validations!
        raise(Ant::Exceptions::AntFail, 'nil value') if @data[:value].nil?
      end
    end

    def json_repository
      @json_repository ||= JSONRepository.new(
        'storage/tuples',
        :key,
        IDGenerators[:id]
      )
    end

    def sequel_repository
      @sequel_repository ||= begin
        db = ::Sequel.sqlite('storage/tuples.db')
        db.create_table? :tuple do
          column :key, :text, size: 40, primary_key: true
          column :value, :text, size: 40
        end
        Sequel.new(
          db[:tuple],
          :key,
          IDGenerators[:id]
        )
      end
    end

    def factory
      @factory ||= begin
        factory = Factory.new(Tuple)
        factory.register(:json, json_repository)
        factory.register('json', json_repository)
        factory.register(:sequel, sequel_repository)
        factory.register('sequel', sequel_repository)
        factory.register(:default, :sequel)
        factory
      end
    end
  end

  helpers FactoryHelpers

  namespace :nanoservice do
    route_param :repository do
      namespace :tuples do
        route_param :id do
          get do
            factory.get(params[:id], params[:repository])
          end

          post do
            data = { key: params[:id], value: params[:value] }
            factory.create(data, params[:repository])
          end
        end
      end
    end
  end

  class AuthenticationError < Ant::Exceptions::AntFail
    def initialize
      super('Unauthorized. Please provide proper keys')
    end

    def http_code
      401
    end
  end

  module AuthHelper
    def current_user!
      token = env['HTTP_AUTHORIZATION']
      raise(AuthenticationError) unless token && /^Basic .*/.match(token)
      data = token.tr('Basic ', '')
      user, pass = Base64.decode64(data).split(':')
      raise(AuthenticationError) unless user == 'test' && pass == 'secret'
      user
    end
  end

  helpers AuthHelper

  namespace :secret do
    get do
      user = current_user!
      { money: 1000, user: user }
    end
  end
end
