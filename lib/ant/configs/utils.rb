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

      def recursive_set(hash, key, value)
        current = key[0]
        if key.size == 1
          hash[current] = value
          hash
        else
          hash[current] ||= {}
          recursive_set(hash[current], key[1..-1], value)
        end
      end

      def split_env_string(string)
        strings = string.split(/(?<!\\),/).map { |str| str.gsub('\,', ',') }
        strings.size == 1 ? strings.first : strings
      end
    end
  end
end
