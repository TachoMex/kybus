# frozen_string_literal: true

module Kybus
  module Configuration
    # This module provides some operations with strings and hashes that
    # are commonly used while parsing or merging strings
    module Utils
      # Ensures that a value is an array. If it is not an array it wraps it
      # inside an array
      # ==== Examples
      #   array_wrap(1) => [1]
      #   array_wrap([1, 2, 3]) => [1, 2, 3]
      def array_wrap(value)
        value.is_a?(Array) ? value : [value]
      end

      # Merges two hashes into one, but if a key is also a hash it will merge
      # it too. This is applied recursively
      # ==== Examples
      #   a = { a: 1, b: { c: 2 } }
      #   b = { b: { d: 3 }, e: 4}
      #   recursive_merge(a, b) => { a: 1, b: { c: 2, d: 3 }, e: 4}
      # rubocop: disable Metrics/AbcSize
      def recursive_merge(receiver, sender)
        return receiver if sender.nil?

        result = receiver.dup
        (receiver.keys + sender.keys).each do |key|
          value = if receiver[key].is_a?(Hash)
                    recursive_merge(receiver[key], sender[key])
                  elsif receiver[key].is_a?(Array)
                    # TODO: Enable merging arrays
                    sender[key]
                  else
                    sender[key]
                  end
          result[key] = value if value
        end
        result
      end
      # rubocop: enable Metrics/AbcSize

      # Takes a hash, an array and a value
      # It will traverse recursively into the hash and create a key inside the
      # hash using the string inside key
      # === Examples
      #   recursive_set({}, %w[hello key], 3) => { 'hello' => { 'key' => 3 } }
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

      # This method is used to parse values from vars passed from ENV or ARGV.
      # Currently all the values are passed as either string or Array of String.
      # The delimiter used is ',' and it allows to escape it
      # === Examples
      #   split_env_string('hello') => 'hello'
      #   split_env_string('hello, world') => ['hello', 'world']
      #   split_env_string('hello\, world') => 'hello, world'
      def split_env_string(string)
        return string unless string.is_a?(String)
        strings = string.split(/(?<!\\),/)
                        .map { |str| str.gsub('\,', ',') }
                        .map { |str| parse_type(str) }
        strings.size == 1 ? strings.first : strings
      end

      def parse_type(string)
        case string.downcase
        when 'true'
          true
        when 'false'
          false
        else
          int = string.to_i
          if int.to_s == string
            int
          else
            string
          end
        end
      end

      def symbolize(hash)
        hash.each_with_object({}) { |(k, v), h| h[k.to_sym] = v }
      end
    end
  end
end
