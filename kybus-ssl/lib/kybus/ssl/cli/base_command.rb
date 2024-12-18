# frozen_string_literal: true

module Kybus
  module SSL
    module CLI
      class BaseCommand
        def initialize(opts)
          @opts = opts
        end

        def transform_keys_recursively(hash)
          hash.each_with_object({}) do |(key, value), new_hash|
            new_key = key.is_a?(Symbol) ? key.to_s : key
            new_value = if value.is_a?(Hash)
                          transform_keys_recursively(value)
                        elsif value.is_a?(Array)
                          value.map { |v| transform_keys_recursively(v) }
                        else
                          value
                        end
            new_hash[new_key] = new_value
          end
        end

        def opts_to_cert_config(keys, extra_args)
          cert = {}
          keys.each { |key| cert[key] = @opts[key] }
          cert.merge(extra_args).compact
        end

        def load_template
          @template = YAML.load_file(@opts[:pki_file])
        end

        def save_template
          @template = transform_keys_recursively(@template)
          File.write(@opts[:pki_file], @template.to_yaml)
        end

        def next_serial
          @template['serial_counter'] += 1
        end

        def pki_file_exist?
          File.file?(@opts[:pki_file])
        end
      end
    end
  end
end
