# frozen_string_literal: true

module Ant
  module DRY
    autoload(:Daemon, 'ant/dry/daemon.rb')
    autoload(:ResourceInjector, 'ant/dry/resource_injector.rb')
  end
  autoload(:Exceptions, 'ant/exceptions.rb')
end
