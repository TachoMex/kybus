module Ant
  module Configuration
    module Utils
      def array_wrap(value)
        value.is_a?(Array) ? value : [value]
      end

      def recursive_merge(receiver, sender)
        return receiver if sender.nil?

        result = receiver.dup
        (receiver.keys + sender.keys).each do |key|
          value = if receiver[key].is_a?(Hash)
                    recursive_merge(receiver[key], sender[key])
                  elsif receiver[key].is_a?(Array)
                    sender[key]
                  else
                    sender[key]
                  end
          result[key] = value if value
        end
        result
      end

      def split_env_string(string)
        string.split(/(?<!\\),/).map { |str| str.gsub('\,', ',') }
      end
    end
  end
end
