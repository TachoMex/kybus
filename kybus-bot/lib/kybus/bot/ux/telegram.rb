# frozen_string_literal: true

module Kybus
  module Bot
    module UX
      # Telegram renderer with reply keyboard and edit-in-place.
      class Telegram < Base
        def render_paginated(dsl, key:, text:, prev_cmd:, next_cmd:)
          markup = build_reply_markup(prev_cmd, next_cmd)
          channel = dsl.current_channel
          meta_key = key.to_s.to_sym
          message_id = dsl.metadata.dig(:pagination, meta_key, :message_id)
          if message_id.nil? && dsl.last_message&.callback
            message_id = dsl.last_message.message_id
          end

          if message_id && @provider.respond_to?(:edit_message_text)
            response = @provider.edit_message_text(channel, message_id, text, reply_markup: markup)
            return if response
          end

          response = if @provider.respond_to?(:send_message_with_markup)
                       @provider.send_message_with_markup(text, channel, reply_markup: markup)
                     else
                       @provider.send_message(text, channel)
                     end
          if response
            message = @provider.message_builder(response)
            store_message_id(dsl, meta_key, message)
          end

          dsl.save_metadata!
        end

        def render_help_overview(dsl, text:, commands:)
          markup = build_help_markup(commands)
          @provider.send_message_with_markup(text, dsl.current_channel, reply_markup: markup)
        end

        def render_help_command(dsl, text:)
          @provider.send_message(text, dsl.current_channel)
        end

        private

        def build_reply_markup(prev_cmd, next_cmd)
          buttons = []
          buttons << build_button('⬅️', prev_cmd) if prev_cmd
          buttons << build_button('➡️', next_cmd) if next_cmd
          return nil if buttons.empty?

          build_markup([buttons])
        end

        def build_help_markup(commands)
          rows = commands.each_slice(2).map do |slice|
            slice.map { |cmd| build_button(cmd, cmd) }
          end
          build_markup(rows)
        end

        def build_button(text, callback_data)
          if defined?(::Telegram::Bot::Types::InlineKeyboardButton)
            ::Telegram::Bot::Types::InlineKeyboardButton.new(text: text, callback_data: callback_data)
          else
            { text: text, callback_data: callback_data }
          end
        end

        def build_markup(rows)
          if defined?(::Telegram::Bot::Types::InlineKeyboardMarkup)
            ::Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: rows)
          else
            { inline_keyboard: rows }
          end
        end

        def store_message_id(dsl, key, message)
          message_id = message&.message_id
          return unless message_id

          metadata = dsl.metadata
          metadata[:pagination] ||= {}
          metadata[:pagination][key.to_sym] = { message_id: message_id }
        end
      end
    end
  end
end
