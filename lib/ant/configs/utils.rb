module Ant
  module Configuration
    module Utils
      def array_wrap(value)
        value.is_a?(Array) ? value : [value]
      end

      def recursive_merge(receiver, sender)
        result = receiver.dup
        (receiver.keys + sender.keys).each do |key|
          if receiver[key].is_a?(Hash)
            receiver[key] = recursive_merge(receiver, sender)
          elsif receiver[key].is_a?(Array)
            # TODO: Implement merge strategy for arrays
            result[key] = sender[key]
          else
            result[key] = sender[key]
          end
        end
        result
      end
    end
  end
end
