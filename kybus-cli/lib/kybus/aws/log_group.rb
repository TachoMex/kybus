# frozen_string_literal: true

module Kybus
  module AWS
    class LogGroup < Resource
      def initialize(config, name)
        super(config)
        @name = name
      end

      def logs_client
        @logs_client ||= Aws::CloudWatchLogs::Client.new(region: @region)
      end

      def log_group_name
        "/aws/lambda/#{@name}"
      end

      def create_or_update!
        logs_client.create_log_group(log_group_name:)
        puts "Log group '#{log_group_name}' created."
      rescue Aws::CloudWatchLogs::Errors::ResourceAlreadyExistsException
        puts "Log group '#{log_group_name}' already exists."
      end

      def destroy!
        logs_client.delete_log_group(log_group_name:)
        puts "Log group '#{log_group_name}' deleted."
      rescue Aws::CloudWatchLogs::Errors::ResourceNotFoundException
        puts "Log group '#{log_group_name}' not found."
      end
    end
  end
end
