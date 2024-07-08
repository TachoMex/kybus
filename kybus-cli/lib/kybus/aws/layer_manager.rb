# frozen_string_literal: true

require 'digest'

def calculate_md5(file_path)
  md5 = Digest::MD5.new
  File.open(file_path, 'rb') do |file|
    buffer = String.new
    md5.update(buffer) while file.read(4096, buffer)
  end
  md5.hexdigest
end

module Kybus
  module AWS
    class LayerManager
      def initialize(lambda_client, function_name)
        @lambda_client = lambda_client
        @function_name = function_name
      end

      def create_or_update_layer(zip_file, layer_name, checksum_file)
        layer_exists = layer_version_exists?(layer_name)
        zipfile_hash = calculate_md5(checksum_file)

        if !layer_exists || layer_exists.description != zipfile_hash
          create_layer(zip_file, layer_name, zipfile_hash)
        else
          puts "Layer unmodified: #{layer_name}"
          layer_exists.layer_version_arn
        end
      end

      def create_layer(zip_file, layer_name, zipfile_hash)
        response = @lambda_client.publish_layer_version(
          layer_name:,
          content: { zip_file: File.read(zip_file) },
          description: zipfile_hash,
          compatible_runtimes: ['ruby3.3']
        )
        puts "Layer '#{layer_name}' created: #{response.layer_version_arn}"
        response.layer_version_arn
      end

      def layer_version_exists?(layer_name)
        response = @lambda_client.list_layer_versions(layer_name:, max_items: 1)
        response.layer_versions.first
      rescue Aws::Lambda::Errors::ResourceNotFoundException
        nil
      end

      def get_layer_arn(layer_name)
        layer_version = layer_version_exists?(layer_name)
        layer_version&.layer_version_arn
      end
    end
  end
end
