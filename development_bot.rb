# frozen_string_literal: true

require 'cute_logger'
require 'ant/configs'
require 'ant/bot'
require 'awesome_print'

require_relative 'api/lib/services'

bot = Ant::Bot::Base.new(Services.configs['bot'])
bot.register_command('/remindme', %i[what when]) do |params|
  puts "I will remind you to '#{params[:what]}' on #{params[:when]}"
end

bot.run
