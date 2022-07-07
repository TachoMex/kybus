# frozen_string_literal: true

require 'uri'

module Kybus
  module Nanorecord
    class Schema
      class Field
        attr_reader :confs, :type, :name, :extra

        def initialize(name, confs)
          @confs = confs || {}
          @type = @confs['type']&.to_sym || :string
          @name = name.to_sym
          @extra = {
            null: @confs['not_null'],
            index: build_index
          }.compact
        end

        def build_index
          (@confs['unique'] || @confs['index']) && { unique: !!@confs['unique'] }
        end

        def build_regex
          case @confs['regex']
          when 'email'
            URI::MailTo::EMAIL_REGEXP
          when String
            /#{@confs['regex']}/
          end
        end

        def build_uniqueness
          if @confs['case_sensitive'].nil?
            @confs['unique']
          elsif !@confs['case_sensitive']
            { case_insensitive: true }
          else
            { case_insensitive: false }
          end
        end

        def build_validations
          {
            presence: @confs['not_null'],
            length: { minimum: @confs['min_size'], maximum: @confs['size'] }.compact_blank,
            uniqueness: build_uniqueness,
            format: { with: build_regex }.compact_blank
          }.compact_blank
        end

        def apply_validations(klass)
          validations = build_validations
          klass.validates(name, validations) unless validations.empty?
        end
      end
    end
  end
end
