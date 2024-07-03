# frozen_string_literal: true

module Kybus
  class CLI < Thor
    class BotDeployerBase
      def initialize(configs)
        @config = configs
      end

      def function_name
        "#{@config[:env] || 'production'}-#{@config['name']}"
      end

      def account_id
        @account_id ||= begin
          sts_client = Aws::STS::Client.new
          response = sts_client.get_caller_identity
          response.account
        end
      end
    end
  end
end
