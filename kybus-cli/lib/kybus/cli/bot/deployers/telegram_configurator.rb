# frozen_string_literal: true

require_relative 'deployer_base'

module Kybus
  class CLI < Thor
    class BotDeployerTelegramConfigurator < BotDeployerBase
      attr_reader :url

      def initialize(url, config)
        @url = url
        super(config)
      end

      def url=(url)
        fail "Empty Webhook URL" if url.nil?
        @url = url
      end

      def create_or_update!
        raise 'Missing Token' if @config['secret_token'].nil?

        uri = URI("https://api.telegram.org/bot#{@config['bot_token']}/setWebhook")
        params = { url: @url, secret_token: @config['secret_token'] }
        puts({msg: 'Making request to', url: uri, params: }.to_yaml)
        res = Net::HTTP.post_form(uri, params)
        puts res.body
      end

      def destroy!
        uri = URI("https://api.telegram.org/bot#{@config['bot_token']}/setWebhook")
        params = { url: '', secret_token: '' }
        res = Net::HTTP.post_form(uri, params)
        puts res.body
      end
    end
  end
end
