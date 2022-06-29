# frozen_string_literal: true

require 'kybus/dry/resource_injector'
require_relative 'nanorecord/schema'

module Kybus
  module Nanorecord
    def self.load_schema!(path)
      Schema.load_file!(path)
    end
  end
end
