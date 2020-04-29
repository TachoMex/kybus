# frozen_string_literal: true

module Kybus
  module DRY
    autoload(:Daemon, 'kybus/dry/daemon.rb')
    autoload(:ResourceInjector, 'kybus/dry/resource_injector.rb')
  end
  autoload(:Exceptions, 'kybus/exceptions.rb')
end
