# frozen_string_literal: true

require 'kybus/logger'
require 'kybus/configs'
require 'kybus/bot'
require 'awesome_print'

require_relative 'api/lib/services'

bot = Kybus::Bot::Base.new(Services.configs['bot'])
bot.register_command('/remindme', %i[what when]) do |params|
  puts "I will remind you to '#{params[:what]}' on #{params[:when]}"
end

bot.run
