# frozen_string_literal: true

module Kybus
  module Logger
    module Format
      # Format params:
      # - %time
      # - %sev
      # - %pid
      # - %tid
      # - %module: won't work well on singleton classes. Prints the name of the
      #            invoking module
      # - %json: Data object encoded as json
      # default format:
      #   "%time,%sev,%pid,%tid,%module,%json"
      def format_builder(format_string)
        proc do |frmt, sev, time, mod, data|
          meta = {
            '%sev': sev,
            '%time': time,
            '%mod': mod,
            '%pid': Process.pid.to_s(16),
            '%tid': Thread.current.object_id.to_s(16)
          }
          entry = frmt.dup
          meta.each { |k, v| entry.gsub!(k.to_s, v.to_s) }
          # json is slower than the meta records, so it is better to replace
          # in a lazy way.
          # TODO: Move lazy tags to a pluggin-based model.
          entry.gsub('%json', data.to_json) if frmt.include?('%json')
        end.curry.call(format_string)
      end
    end
  end
end
