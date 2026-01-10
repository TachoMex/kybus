# frozen_string_literal: true

module Kybus
  module Bot
    module UX
      # Default renderer: sends new messages with plain text.
      class Base
        def initialize(provider)
          @provider = provider
        end

        def render_paginated(dsl, key:, text:, prev_cmd:, next_cmd:)
          nav = []
          nav << "⬅️ #{prev_cmd}" if prev_cmd
          nav << "➡️ #{next_cmd}" if next_cmd
          body = nav.empty? ? text : [text, nav.join(' ')].join("\n")
          dsl.send_message(body)
        end

        def render_help_overview(dsl, text:, commands:)
          dsl.send_message(text)
        end

        def render_help_command(dsl, text:)
          dsl.send_message(text)
        end
      end
    end
  end
end
